# setup -------------------------------------------------------------------

library(magrittr)
library(decryptr)

# https://github.com/tensorflow/tensorflow/issues/6698#issuecomment-567619685
gpus <- tensorflow::tf$config$experimental$list_physical_devices("GPU")
tensorflow::tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)

d_img <- fs::dir_ls("img") %>% 
  purrr::map_dfr(~{
    l <- as.character(fs::dir_ls(.x, type = "file"))
    tibble::tibble(n = length(l), first = l[1], img = list(l))
  }, .id = "captcha") %>% 
  dplyr::arrange(dplyr::desc(n))

# funs --------------------------------------------------------------------

preprocess_img <- function(x) {
  x %>%
    purrr::map(~{
      decryptr:::decryptr_img_load_tf(.x, c(32L, 128L)) %>% 
        tensorflow::array_reshape(c(1, dim(.))) %>% 
        as.array()
    }) %>% 
    abind::abind(along = 1)
}

# predict -----------------------------------------------------------------


model <- "model_rfb_basic.hdf5" %>% 
  keras::load_model_hdf5(compile = FALSE)

predict_model.lime_classifier <- function(x, newdata, type, ...) {
  letra <- list(...)[["letra"]]
  if (is.null(letra)) letra <- 1
  pred <- t(apply(predict(x, x = as.array(newdata)), 1, function(x) x[letra,,drop=FALSE]))
  colnames(pred) <- as.character(seq_len(ncol(pred)))
  as.data.frame(pred, check.names = FALSE)
}

# img <- d_img$img[[7]][1]
# predict(model, preprocess_img(img))

# superpixels -------------------------------------------------------------

# lime::plot_superpixels(
#   img,
#   n_superpixels = 80,
#   weight = 2,
#   n_iter = 100,
#   colour = "red"
# )

# test lime ---------------------------------------------------------------

p_explain <- function(img, letra = 1) {
  
  message(img)
  
  labs <- c(0:9, letters)
  ans <- stringr::str_extract(img, "(?<=_)[^.]+") %>% 
    stringr::str_sub(letra, letra)
  
  explainer <- lime::lime(
    x = img,
    model = lime::as_classifier(model, labels = labs), 
    preprocess = preprocess_img
  )
  
  da_explain <- lime::explain(
    img,
    # explainer params
    explainer = explainer, 
    n_features = Inf,
    labels = labs, 
    feature_select = "lasso_path",
    n_permutations = 500,
    # super pixels params
    n_superpixels = 80, 
    weight = 2,
    n_iter = 100,
    letra = letra
  )
  
  da_explain %>% 
    dplyr::filter(label == label[which.max(label_prob)[1]]) %>% 
    lime::plot_image_explanation(
      which = 1, 
      threshold = 0.1, 
      display = "outline", 
      block_col = "#DDDDDD11"
    ) +
    ggplot2::labs(title = paste0("Answer: ", ans))
  
}

set.seed(19910401)
imgs <- sample(d_img$img[[3]], 20)
p_explain(imgs[1], letra = 2)

# super plot --------------------------------------------------------------

l <- purrr::map(imgs, p_explain)
library(patchwork)
purrr::reduce(l, `+`) + patchwork::plot_layout(ncol = 5)
