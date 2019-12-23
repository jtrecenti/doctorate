library(magrittr)

f <- fs::dir_ls("img/nfe", type = "file")
length(f)

f %>% fs::file_move()
fs::file_move(f, paste0(fs::path_dir(f), "/captcha_", fs::path_file(f)))


f[1]


decryptr::read_captcha(f[2], ans_in_path = TRUE) %>% 
  dplyr::first() %>% 
  plot()

x <- decryptr::read_captcha(f[2], ans_in_path = TRUE)
str(x[[1]])


readr::write_rds(d_nfe, "d_nfe.rds")

d_nfe$y %>% dim

X <- d_nfe$x
y <- d_nfe$y
d_nfe$n

keras::image_to_array(f[1])

img <- keras::flow_images_from_directory("img/nfe", target_size = c(42, 150))
img$classes


library(keras)
library(magrittr)

set.seed(1)

f <- fs::dir_ls("img/nfe", type = "file")
f_sample <- sample(f, 12000)

X <- f_sample %>% 
  purrr::map(~keras::image_to_array(keras::image_load(.x))) %>% 
  abind::abind(along = 0)

readr::write_rds(X, "X.rds")

y <- f_sample %>% 
  decryptr::read_captcha(ans_in_path = TRUE) %>% 
  decryptr::join_captchas() %>% 
  with(y)

readr::write_rds(y, "y.rds")


library(magrittr)
library(tensorflow)
library(keras)

# https://github.com/tensorflow/tensorflow/issues/6698#issuecomment-567619685
gpus <- tf$config$experimental$list_physical_devices("GPU")
tf$config$experimental$set_memory_growth(gpus[[1]], TRUE)

captcha <- fs::dir_ls("img/rsc") %>% 
  decryptr::read_captcha(ans_in_path = TRUE) %>% 
  decryptr::join_captchas()

y <- captcha$y
X <- captcha$x

# y <- readr::read_rds("y.rds")
# X <- readr::read_rds("X.rds")

input <- layer_input(dim(X)[-1])
output <- input %>% 
  layer_conv_2d(16, c(3,3), padding = "same", activation = "relu") %>% 
  layer_max_pooling_2d() %>% 
  layer_conv_2d(32, c(3,3), padding = "same", activation = "relu") %>% 
  layer_max_pooling_2d() %>% 
  layer_conv_2d(64, c(3,3), padding = "same", activation = "relu") %>% 
  layer_max_pooling_2d() %>% 
  layer_flatten() %>% 
  layer_dense(128, activation = "relu") %>% 
  layer_dropout(.1) %>%
  layer_dense(64, activation = "relu") %>% 
  layer_dropout(.1) %>%
  layer_dense(prod(dim(y)[-1])) %>% 
  layer_reshape(dim(y)[-1]) %>% 
  layer_activation_softmax()

model <- keras_model(input, output)
model

predict(model, X[1,,,,drop=FALSE])[1,,]

model %>% 
  compile(
    optimizer = "adam",
    loss = loss_categorical_crossentropy,
    metrics = "accuracy"
  )

model %>% 
  fit(
    x = X, y = y, 
    epochs = 10,
    batch_size = 32,
    validation_split = 0.2
  )

