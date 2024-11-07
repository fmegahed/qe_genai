

# * Custom Functions  -----------------------------------------------

# A function to generate simulated textile images and save them as JPEG files
gen_and_save_image = function(
    img_type = c('nominal', 'local', 'global'), file_path, width = 250, 
    height = 250, cut_border = 200
    ) {
  # Width, height, and cut_border values are based on the suggested values in 
  # the spc4sts package in R, see P. 8 in
  # https://cran.r-project.org/web/packages/spc4sts/spc4sts.pdf
  if (img_type == 'nominal') {
    img =  spc4sts::sarGen(phi1 = .6, phi2 = .35, m = height, n = width, border = cut_border)
  } else if (img_type == 'local') {
    img =  spc4sts::sarGen(phi1 = .6, phi2 = .35, m = height, n = width, border = cut_border)
    img = spc4sts::imposeDefect(img)$img
  } else if (img_type == 'global') {
    img =  spc4sts::sarGen(phi1 = .6*0.95, phi2 = .35*0.95, m = height, n = width, border = cut_border)
  }
  
  # Open a JPEG device with specified dimensions
  jpeg(file_path, width = width, height = height, units = "px", res = 600)
  
  # Remove the margins
  par(mar = c(0, 0, 0, 0))
  
  # Plot the image
  image(img, col = gray((0:32)/32), xlab="", ylab="", axes = FALSE)
  
  # Close the JPEG device
  dev.off()
}



# * Simulated Image Data from the `spc4sts' Package -----------------------

set.seed(2024)

# Generate 1000 nominal images
purrr::map(1:1000, ~{
  file_path = sprintf("simulated/nominal/textile_%04d.jpg", .x)
  gen_and_save_image(img_type = "nominal", file_path = file_path)
})

# Generate 500 local defect images
purrr::map(1:500, ~{
  file_path = sprintf("simulated/local/textile_%04d.jpg", .x)
  gen_and_save_image(img_type = "local", file_path = file_path)
})

# Generate 500 global defect images
purrr::map(1:500, ~{
  file_path = sprintf("simulated/global/textile_%04d.jpg", .x)
  gen_and_save_image(img_type = "global", file_path = file_path)
})




# * Saving the Real Textile Images from the `textile` Package -------------

save_images = function(image_matrix, file_path) {
  # Set width and height to match the dimensions of the image matrix
  width = ncol(image_matrix)
  height = nrow(image_matrix)
  
  # Open a JPEG device with specified dimensions
  jpeg(file_path, width = width, height = height, units = "px", res = 600)
  
  # Reduce margins to prevent "figure margins too large" error
  par(mar = c(0, 0, 0, 0))  # Set all margins to 0
  
  # Plot the image
  image(1:width, 1:height, as.matrix(t(apply(image_matrix, 2, rev))),
        col = gray((0:32)/32), xlab="", ylab="", axes = FALSE)
  
  # Close the JPEG device
  dev.off()
}

# Create folders for each dataset
dir.create("trainImg", showWarnings = FALSE)
dir.create("icImgs", showWarnings = FALSE)
dir.create("ocImgs", showWarnings = FALSE)

# Save trainImg as a single JPG
data("trainImg")
save_images(trainImg, "trainImg/trainImg.jpg")

# Save each image in icImgs as individual JPGs with four-digit numbering
data("icImgs")
for (i in 1:dim(icImgs)[3]) {
  file_path = sprintf("icImgs/icImg_%04d.jpg", i) 
  save_images(icImgs[,,i], file_path)
}

# Save each image in ocImgs as individual JPGs with four-digit numbering
data("ocImgs")
for (i in 1:dim(ocImgs)[3]) {
  file_path = sprintf("ocImgs/ocImg_%04d.jpg", i) 
  save_images(ocImgs[,,i], file_path)
}
