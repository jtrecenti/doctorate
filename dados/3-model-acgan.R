library(magrittr)
library(decryptr)

# https://github.com/tensorflow/tensorflow/issues/6698#issuecomment-567619685
gpus <- tensorflow::tf$config$experimental$list_physical_devices("GPU")
tensorflow::tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)

# dataset creation ----

d_img <- purrr::map_dfr(fs::dir_ls("img"), ~{
  l <- as.character(fs::dir_ls(.x, type = "file"))
  tibble::tibble(n = length(l), first = l[1], img = list(l))
}, .id = "captcha") %>% 
  dplyr::arrange(dplyr::desc(n))

# plot(decryptr::read_captcha("img/sintegra_rj/Rio_11c3k.png")[[1]])

n_train <- 320
batch_size <-  32L

da <- captcha_prepare_dataset(
  img = d_img$img[[7]],
  n_train = n_train,
  vocab = c(0:9, letters),
  prep_options = captcha_prep_options(img_size = c(32L, 128L))
) %>% 
  purrr::modify_at(1:2, ~{
    .x %>% 
      tfdatasets::dataset_batch(batch_size) %>%
      tfdatasets::dataset_prefetch_to_device("/gpu:0", buffer_size = 1L)
  })
