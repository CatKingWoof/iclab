import numpy as np
import argparse
import bitstring


def ParseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('--patnum', '-p', type=int, default=1)
    args = parser.parse_args()
    return args


def random_float33():
    a = np.random.rand(3, 3)
    return a


def convert2binary33(float_num):
    bit_pattern = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    for i in range(0, 3):
        for j in range(0, 3):
            bit_pattern[i][j] = bitstring.BitArray(
                float=float_num[i][j], length=32)
            bit_pattern[i][j] = bit_pattern[i][j].bin
    '''sign = bit_pattern.bin[0]   # 1 bit
    exp = bit_pattern.bin[1:9]  # 8 bits
    frac = bit_pattern.bin[9:]  # 23 bits
    print(f"Float number: {float_num}  ", sign, exp, frac,
          f"Actually stored Value = {bit_pattern.float}")'''

    return bit_pattern


def random_float31():
    a = np.random.rand(3, 1)
    return a


def convert2binary31(float_num):
    bit_pattern = bitstring.BitArray(float=float_num, length=32)
    bit_pattern = [0, 0, 0]
    for i in range(0, 3):
        bit_pattern[i] = bitstring.BitArray(
            float=float_num[i], length=32)
        bit_pattern[i] = bit_pattern[i].bin
    '''sign = bit_pattern.bin[0]   # 1 bit
    exp = bit_pattern.bin[1:9]  # 8 bits
    frac = bit_pattern.bin[9:]  # 23 bits
    print(f"Float number: {float_num}  ", sign, exp, frac,
          f"Actually stored Value = {bit_pattern.float}")'''
    return bit_pattern


def generate_matrix():
    # generate input from 0 ~ 1
    # -----------------------------------
    U = random_float33()
    V = random_float33()
    W = random_float33()
    h0 = random_float31()
    x1 = random_float31()
    x2 = random_float31()
    x3 = random_float31()
    '''U = np.array([[1, -1, -4], [1, 4, -2], [4, -1, 2]])
    V = np.array([[-1, -1, 1], [-2, -2, -2], [4, 2, -4]])
    W = np.array([[-4, 1, -2], [-4, 2, 2], [4, 2, -4]])
    h0 = np.array([[-1], [-4], [-4]])
    x1 = np.array([[-2], [4], [2]])
    x2 = np.array([[4], [1], [-2]])
    x3 = np.array([[-4], [-4], [2]])'''
    # -----------------------------------
    h1 = Leaky_ReLU(np.dot(U, x1)+np.dot(W, h0))
    h2 = Leaky_ReLU(np.dot(U, x2)+np.dot(W, h1))
    h3 = Leaky_ReLU(np.dot(U, x3)+np.dot(W, h2))
    y1 = sigmoid(np.dot(V, h1))
    y2 = sigmoid(np.dot(V, h2))
    y3 = sigmoid(np.dot(V, h3))

    return U, V, W, h0, x1, x2, x3, y1, y2, y3


def sigmoid(x):
    return 1 / (1 + np.exp(-x))


def Leaky_ReLU(x):
    y1 = ((x > 0)*x)
    y2 = ((x <= 0)*x*0.1)
    return y1+y2


def main():
    args = ParseArgs()
    patnum = args.patnum
    Uf = open('U.txt', 'w')
    Vf = open('V.txt', 'w')
    Wf = open('W.txt', 'w')
    IN = open('input.txt', 'w')
    Hf = open('H.txt', 'w')
    OUT = open('output.txt', 'w')
    for i in range(patnum):
        U, V, W, h0, x1, x2, x3, y1, y2, y3 = generate_matrix()
        U = convert2binary33(U)
        V = convert2binary33(V)
        W = convert2binary33(W)
        h0 = convert2binary31(h0)
        x1 = convert2binary31(x1)
        x2 = convert2binary31(x2)
        x3 = convert2binary31(x3)
        y1 = convert2binary31(y1)
        y2 = convert2binary31(y2)
        y3 = convert2binary31(y3)
        for i in range(0, 3):
            for j in range(0, 3):
                Uf.write(str(U[j][i])+'\n')
                Wf.write(str(W[j][i])+'\n')
                Vf.write(str(V[j][i])+'\n')
        for i in range(0, 3):
            Hf.write(str(h0[i])+'\n')
        for i in range(0, 3):
            IN.write(str(x1[i])+'\n')
        for i in range(0, 3):
            IN.write(str(x2[i])+'\n')
        for i in range(0, 3):
            IN.write(str(x3[i])+'\n')
        for i in range(0, 3):
            OUT.write(str(y1[i])+'\n')
            OUT.write(str(y2[i])+'\n')
            OUT.write(str(y3[i])+'\n')
        Uf.write('\n')
        Wf.write('\n')
        Vf.write('\n')
        IN.write('\n')
        Hf.write('\n')
        OUT.write('\n')
    Uf.close()
    Vf.close()
    Wf.close()
    Hf.close()
    IN.close()
    OUT.close()


if __name__ == "__main__":
    main()
