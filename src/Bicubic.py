import numpy as np
from PIL import Image

def toThreeChannel(input):
    M, N = input.shape
    output = np.zeros((input.shape[0], input.shape[1], 3))

    for i in range(M):
        for j in range(N):
            pixel = input[i,j]
            output[i,j] = np.array([pixel, pixel, pixel])
    
    return output

def getWeight(X):
    x = abs(X)
    weight = 0.0

    if x >= 0 and x <= 1:
        weight = 1.5*(x*x*x) - 2.5*(x*x) + 1
    elif x > 1 and x <= 2:
        weight = (-0.5)*(x*x*x) + 2.5*(x*x) - 4*x + 2
    elif x > 2:
        weight = 0.0
    
    return weight

def pixelBoundary(pixel):
    new_pixel = pixel
    for i in range(3):
        if new_pixel[i] < 0:
            new_pixel[i] = 0
        elif new_pixel[i] > 255:
            new_pixel[i] = 255
    return new_pixel

def boundaryCondition(a, b, c):
    return pixelBoundary(pixelBoundary(pixelBoundary(3*a) - pixelBoundary(3*b))+c)

def bicubic(input, shape):
    new_row, new_col = shape
    output = np.zeros((new_row, new_col, 3))
    M, N = (input.shape[0], input.shape[1])
    extended_input = np.zeros((M+3, N+3, 3), dtype='int64')
    before = input

    if len(input.shape) == 2:               ## input is single-channel
        before = toThreeChannel(before)

    extended_input[1:M+1,1:N+1] = before.astype('int64')[:,:]

    ## (-1, k) for k=0, 1, ..., N-1
    ## ( M, k) for k=0, 1, ..., N-1
    for i in range(1,N+1):
        extended_input[0,i] = boundaryCondition(extended_input[1,i], extended_input[2,i], extended_input[3,i])
        extended_input[M+1,i] = boundaryCondition(extended_input[M,i], extended_input[M-1,i], extended_input[M-2,i])
        extended_input[M+2,i] = boundaryCondition(extended_input[M+1,i], extended_input[M,i], extended_input[M-1,i])
    
    ## (k, -1) for k=0, 1, ..., M-1
    ## (k, N) for k=0, 1, ..., M-1
    for i in range(1,M+1):
        extended_input[i,0] = boundaryCondition(extended_input[i,1], extended_input[i,2], extended_input[i,3])
        extended_input[i,N+1] = boundaryCondition(extended_input[i,N], extended_input[i,N-1], extended_input[i,N-2])
        extended_input[i,N+2] = boundaryCondition(extended_input[i,N+1], extended_input[i,N], extended_input[i,N-1])

    ## (-1, -1)
    extended_input[0,0] = boundaryCondition(extended_input[1,0], extended_input[2,0], extended_input[3,0])

    ## (M, -1), (M+1, -1)
    extended_input[M+1,0] = boundaryCondition(extended_input[M,0], extended_input[M-1,0], extended_input[M-2,0])
    extended_input[M+2,0] = boundaryCondition(extended_input[M+1,0], extended_input[M,0], extended_input[M-1,0])

    ## (-1, N), (-1, N+1)
    extended_input[0,N+1] = boundaryCondition(extended_input[1,N+1], extended_input[2,N+1], extended_input[3,N+1])
    extended_input[0,N+2] = boundaryCondition(extended_input[1,N+2], extended_input[2,N+2], extended_input[3,N+2])

    ## (M, N), (M, N+1), (M+1, N), (M+1, N+1)
    extended_input[M+1,N+1] = boundaryCondition(extended_input[M,N+1], extended_input[M-1,N+1], extended_input[M-2,N+1])
    extended_input[M+1,N+2] = boundaryCondition(extended_input[M,N+2], extended_input[M-1,N+2], extended_input[M-2,N+2])
    extended_input[M+2,N+1] = boundaryCondition(extended_input[M+1,N+1], extended_input[M,N+1], extended_input[M-1,N+1])
    extended_input[M+2,N+2] = boundaryCondition(extended_input[M+1,N+2], extended_input[M,N+2], extended_input[M-1,N+2])

    ratioX = float(M) / new_row
    ratioY = float(N) / new_col

    for i in range(new_row):
        for j in range(new_col):
            x = i * ratioX
            y = j * ratioY
            temp = np.array([0.0, 0.0, 0.0], dtype=np.double)

            for k in range(4):
                for l in range(4):
                    m = int(x)+k-1
                    n = int(y)+l-1
                    temp = temp + extended_input[m+1, n+1]*(getWeight(x - m)*getWeight(y - n))
            
            temp = pixelBoundary(temp)
            output[i,j] = np.round(temp)
    
    return output.astype('uint8')
