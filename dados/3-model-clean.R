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

n_train <- 5000
batch_size <-  64L

da <- captcha_prepare_dataset(
  img = d_img$img[[3]],
  n_train = n_train,
  vocab = c(0:9, letters),
  prep_options = captcha_prep_options(img_size = c(32L, 128L))
) %>% 
  purrr::modify_at(1:2, ~{
    .x %>% 
      tfdatasets::dataset_batch(batch_size) %>%
      tfdatasets::dataset_prefetch_to_device("/gpu:0", buffer_size = 1L)
  })


# neural network specs ----

input <- keras::layer_input(da$shape$x)

output <- input %>% 
  keras::layer_conv_2d(16, c(5,5), padding = "same", activation = "relu") %>% 
  keras::layer_max_pooling_2d() %>% 
  keras::layer_conv_2d(32, c(5,5), padding = "same", activation = "relu") %>% 
  keras::layer_max_pooling_2d() %>% 
  keras::layer_conv_2d(64, c(3,3), padding = "same", activation = "relu") %>% 
  keras::layer_max_pooling_2d() %>% 
  keras::layer_flatten() %>% 
  keras::layer_dense(128, activation = "relu") %>% 
  keras::layer_dropout(.5) %>%
  keras::layer_dense(prod(da$shape$y)) %>% 
  keras::layer_reshape(da$shape$y) %>% 
  keras::layer_activation_softmax()

(model <- keras::keras_model(input, output))

model %>% 
  keras::compile(
    optimizer = keras::optimizer_adam(lr = 0.01),
    loss = loss_categorical_crossentropy,
    metrics = "accuracy"
  )

# fit model ----

# preciso dar shuffle

model %>% 
  keras::fit(
    da$train,
    epochs = 100,
    validation_data = da$validation
  )

# export ----

# readr::write_rds(da, paste0("model_rsc_out/da_", n_train, ".rds"))
# keras::save_model_hdf5(model, paste0("model_rsc_out/m_", n_train, ".hdf5"))

keras::save_model_hdf5(model, "model_rfb_basic.hdf5", include_optimizer = TRUE)


