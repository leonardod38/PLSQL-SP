#!/usr/bin/env python
# coding: utf-8

# <h1>RGB to grayscale</h1>

# In this exercise you will load an image from scikit-image module data and make it grayscale, then compare both of them in the output.
# 
# We have preloaded a function show_image(image, title='Image') that displays the image using Matplotlib. You can check more about its parameters using ?show_image() or help(show_image) in the console.

# In[4]:


from IPython.display import Image
Image(filename='notebookpics/rocket.png')


# In[ ]:


# Import the modules from skimage
from skimage import ____, ____

# Load the rocket image
rocket = data.____

# Convert the image to grayscale
gray_scaled_rocket = color.____(____)

# Show the original image
show_image(rocket, 'Original RGB image')

# Show the grayscale image
show_image(gray_scaled_rocket, 'Grayscale image')


# # Instructions

# <li>Import the modules from Scikit image.</li>
# <li>Load the rocket image.</li>
# <li>Convert the RGB-3 rocket image to grayscale.</li>

# # Hint

# <li>Import data and color from Scikit image.</li>
# <li>Load the rocket image from data module.</li>
# <li>Convert the RGB-3 rocket image to grayscale, using the function rgb2gray().</li>

# # Solution

# ```python
# 
# # Import the modules from skimage
# from skimage import data, color
# 
# # Load the rocket image
# rocket = data.rocket()
# 
# # Convert the image to grayscale
# gray_scaled_rocket = color.rgb2gray(rocket) 
# 
# # Show the original image
# show_image(rocket, 'Original RGB image')
# 
# # Show the grayscale image
# show_image(gray_scaled_rocket, 'Grayscale image')
# 
# ```

# In[ ]:
