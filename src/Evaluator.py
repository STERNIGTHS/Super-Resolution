import numpy as np

YCbCr = np.array([[0.299, 0.587, 0.114],[-0.168736, -0.331264, 0.5],[0.5, -0.418688, -0.081312]])

def ycbcr(input):
    output = np.zeros(input.shape)
    M, N = (input.shape[0], input.shape[1])

    for i in range(M):
        for j in range(N):
            pixel = input[i,j]
            output[i,j,0] = np.dot(YCbCr[0], pixel)
            output[i,j,1] = 128 + np.dot(YCbCr[1], pixel)
            output[i,j,2] = 128 + np.dot(YCbCr[2], pixel)

    return output

def gaussianWeight(size, std):
    size_tmp = (size - 1) / 2
    x = np.array([[j for j in range(-1*size_tmp, size_tmp+1)] for i in range(size)])
    y = np.array([[i-5 for j in range(-1*size_tmp, size_tmp+1)] for i in range(size)])
    arg = -(x*x + y*y) / (2*std*std)
    h = np.exp(arg)
    sumh = np.sum(h)
    h = h / sumh
    return h

def filter2d(input_img, filter):
    P, Q = input_img.shape
    M, N = filter.shape
    temp_im = np.zeros((P-M+1,Q-N+1))
    for i in range(0, P-M+1):
        for j in range(0, Q-N+1):
            temp = np.sum(input_img[i:i+M, j:j+N] * filter)
            temp_im[i][j] = temp
    return temp_im

def PSNR(input_img1, input_img2):
    img1 = input_img1
    img2 = input_img2
    
    if len(input_img1.shape) == 3:      ## input is rgb
        img1 = ycbcr(img1)[:,:,0].astype('double')
    if len(input_img2.shape) == 3:
        img2 = ycbcr(img2)[:,:,0].astype('double')

    M, N = img1.shape
    mse = 0.0

    for i in range(M):
        for j in range(N):
            mse = mse + pow((img1[i,j] - img2[i,j]),2)
    
    mse = mse / float(M*N)
    return 20 * np.log10(255.0/np.sqrt(mse))

def MSSIM(input_img1, input_img2):
    img1 = input_img1.astype('double')
    img2 = input_img2.astype('double')
    
    if len(input_img1.shape) == 3:      ## input is rgb
        img1 = ycbcr(img1)[:,:,0]
    if len(input_img2.shape) == 3:
        img2 = ycbcr(img2)[:,:,0]

    gw = gaussianWeight(11, 1.5)
    c1 = pow(0.01*255, 2)
    c2 = pow(0.03*255, 2)
    mu1 = filter2d(img1, gw)
    mu2 = filter2d(img2, gw)
    mu1_sq = mu1 * mu1
    mu2_sq = mu2 * mu2
    mu1_mu2 = mu1 * mu2
    sigma1_sq = filter2d(img1 * img1, gw) - mu1_sq
    sigma2_sq = filter2d(img2 * img2, gw) - mu2_sq
    sigma12 = filter2d(img1 * img2, gw) - mu1_mu2

    ssim_map = ((2*mu1_mu2 + c1)*(2*sigma12 + c2)) / \
               ((mu1_sq + mu2_sq + c1)*(sigma1_sq + sigma2_sq + c2))

    return np.mean(ssim_map)