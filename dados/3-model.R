# library(magrittr)
# 
# f <- fs::dir_ls("img/nfe", type = "file")
# length(f)
# 
# f %>% fs::file_move()
# fs::file_move(f, paste0(fs::path_dir(f), "/captcha_", fs::path_file(f)))
# 
# 
# f[1]
# 
# 
# decryptr::read_captcha(f[2], ans_in_path = TRUE) %>% 
#   dplyr::first() %>% 
#   plot()
# 
# x <- decryptr::read_captcha(f[2], ans_in_path = TRUE)
# str(x[[1]])
# 
# 
# readr::write_rds(d_nfe, "d_nfe.rds")
# 
# d_nfe$y %>% dim
# 
# X <- d_nfe$x
# y <- d_nfe$y
# d_nfe$n
# 
# keras::image_to_array(f[1])
# 
# img <- keras::flow_images_from_directory("img/nfe", target_size = c(42, 150))
# img$classes
# 
# 
# library(keras)
# library(magrittr)
# 
# set.seed(1)
# 
# f <- fs::dir_ls("img/nfe", type = "file")
# f_sample <- sample(f, 12000)
# 
# X <- f_sample %>% 
#   purrr::map(~keras::image_to_array(keras::image_load(.x))) %>% 
#   abind::abind(along = 0)
# 
# readr::write_rds(X, "X.rds")
# 
# y <- f_sample %>% 
#   decryptr::read_captcha(ans_in_path = TRUE) %>% 
#   decryptr::join_captchas() %>% 
#   with(y)
# 
# readr::write_rds(y, "y.rds")


# library(magrittr)
# library(tensorflow)
# library(keras)


# captcha <- fs::dir_ls("img/rfb/") %>%
#   sample(6000) %>% 
#   decryptr::read_captcha(ans_in_path = TRUE) %>%
#   decryptr::join_captchas()
# #
# readr::write_rds(captcha, "rfb.rds")
# captcha <- readr::read_rds("rfb.rds")

# s <- sample(seq_len(captcha$n), n_train)

# rsz <- function(img) {
#   tensorflow::tf$image$resize(img, c(24L, 72L))
# }

# y_train <- captcha$y[s,,,drop=FALSE]
# x_train <- rsz(captcha$x[s,,,,drop=FALSE])
# 
# y_test <- captcha$y[-s,,,drop=FALSE]
# x_test <- rsz(captcha$x[-s,,,,drop=FALSE])

# datagen <- image_data_generator(
#   rotation_range = 20,
#   width_shift_range = 0.1,
#   height_shift_range = 0.1,
#   shear_range = 1,
#   zoom_range = .2
# )

# x1 %>% 
#   magrittr::extract2(1) %>% 
#   magrittr::extract(1,,,1) %>% 
#   as.matrix() %>% 
#   as.raster() %>% 
#   plot()

# res <- purrr::map(c(seq(100, 900, 200), seq(1000, 5000, 500)), ajustar_com_n)
# ajustar_com_n_trt(5500)

# 
# j <- 10
# 
# pred_ind <- predict(model, x_test[j,,,,drop = FALSE])[1,,] %>% 
#   apply(1, which.max)
# label <- paste(decryptr:::get_answer(rownames(y_test[j,,,drop=FALSE]), NULL), collapse = "")
# pred <- paste(dimnames(y_test)[[3]][pred_ind], collapse = "")
# 
# label == pred
# 
# 

# library(ggplot2)
# rsc <- tibble::tribble(
#   ~n, ~acc,
#   0100, .1920,
#   0300, .4801,
#   0500, .7358,
#   0700, .8691,
#   1000, .9357,
#   1500, .9726,
#   2000, .9861,
#   2500, .9924,
#   3000, .9941,
#   4000, .9952,
#   5000, .9911
# ) %>% 
#   ggplot(aes(x = n, y = acc)) +
#   geom_point() +
#   geom_line()
# 
# 
# 
# 
# readr::write_rds(data, paste0("model_rsc_out/data_", n_train, ".rds"))
# keras::save_model_hdf5(model, paste0("model_rsc_out/m_", n_train, ".hdf5"))
# 
# set.seed(1)
# ajustar_com_n("img/rsc", 5000)




