import numpy as np
import argparse


def ParseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('--patnum', '-p', type=int, default=1)
    args = parser.parse_args()
    return args


def generate_matrix():
    # generate input from 0 ~ 1
    # -----------------------------------
    U = sigmoid(np.random.randn(3, 3))
    V = sigmoid(np.random.randn(3, 3))
    W = sigmoid(np.random.randn(3, 3))
    h0 = sigmoid(np.random.randn(3, 1))
    x1 = sigmoid(np.random.randn(3, 1))
    x2 = sigmoid(np.random.randn(3, 1))
    x3 = sigmoid(np.random.randn(3, 1))
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
    Hf = open('H.txt', 'w')
    IN = open('input.txt', 'w')
    OUT = open('output.txt', 'w')
    for i in range(patnum):
        U, V, W, h0, x1, x2, x3, y1, y2, y3 = generate_matrix()
        for j in range(9):
            # 00 -> 01 -> 02 -> 10 ...
            q = j // 3
            r = j % 3
            Uf.write(str(U[q, r])+'\n')
            Wf.write(str(W[q, r])+'\n')
            Vf.write(str(V[q, r])+'\n')

            if (q == 0):
                IN.write(str(x1[r, 0])+'\n')
                OUT.write(str(y1[r, 0])+'\n')
            if (q == 1):
                IN.write(str(x2[r, 0])+'\n')
                OUT.write(str(y2[r, 0])+'\n')
            if (q == 2):
                IN.write(str(x3[r, 0])+'\n')
                OUT.write(str(y3[r, 0])+'\n')
        for i in range(0, 3):
            Hf.write(str(h0[i, 0])+'\n')

        Uf.write('\n')
        Wf.write('\n')
        Vf.write('\n')
        IN.write('\n')
        OUT.write('\n')
        Hf.write('\n')

    Uf.close()
    Vf.close()
    Wf.close()
    IN.close()
    OUT.close()
    Hf.close()


if __name__ == "__main__":
    main()
