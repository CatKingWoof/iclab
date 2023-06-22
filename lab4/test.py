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
    U = np.array([[1, -1, -4], [1, 4, -2], [4, -1, 2]])
    V = np.array([[-1, -1, 1], [-2, -2, -2], [4, 2, -4]])
    W = np.array([[-4, 1, -2], [-4, 2, 2], [4, 2, -4]])
    h0 = np.array([[-1], [-4], [-4]])
    x1 = np.array([[-2], [4], [2]])
    x2 = np.array([[4], [1], [-2]])
    x3 = np.array([[-4], [-4], [2]])
    # -----------------------------------

    h1 = Leaky_ReLU(np.dot(U, x1)+np.dot(W, h0))
    print(h1)
    h2 = Leaky_ReLU(np.dot(U, x2)+np.dot(W, h1))
    print(h2)
    h3 = Leaky_ReLU(np.dot(U, x3)+np.dot(W, h2))
    print(h3)
    y1 = sigmoid(np.dot(V, h1))
    print(np.dot(V, h1))
    print(np.dot(V, h2))
    print(np.dot(V, h3))
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
