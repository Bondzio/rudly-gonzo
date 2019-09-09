{import
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "<img src=\"../../images/qiskit-heading.gif\" alt=\"Note: In order for images to show up in this jupyter notebook you need to select File => Trusted Notebook\" width=\"500 px\" align=\"left\">"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Summary of Quantum Operations "
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    " In this section we will go into the different operations that are available in Qiskit Terra. These are:\n",
    "- Single-qubit quantum gates\n",
    "- Multi-qubit quantum gates\n",
    "- Measurements\n",
    "- Reset\n",
    "- Conditionals\n",
    "- State initialization\n",
    "\n",
    "We will also show you how to use the three different simulators:\n",
    "- unitary_simulator\n",
    "- qasm_simulator\n",
    "- statevector_simulator"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:22.356783Z",
     "start_time": "2018-09-29T00:15:22.017905Z"
    }
   },
   "outputs": [],
   "source": [
    "# Useful additional packages \n",
    "import matplotlib.pyplot as plt\n",
    "%matplotlib inline\n",
    "import numpy as np\n",
    "from math import pi"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 2,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:24.371649Z",
     "start_time": "2018-09-29T00:15:22.358409Z"
    }
   },
   "outputs": [],
   "source": [
    "from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister, execute\n",
    "from qiskit.tools.visualization import circuit_drawer\n",
    "from qiskit.quantum_info import state_fidelity\n",
    "from qiskit import BasicAer\n",
    "\n",
    "backend = BasicAer.get_backend('unitary_simulator')"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Single Qubit Quantum states\n",
    "\n",
    "A single qubit quantum state can be written as\n",
    "\n",
    "$$\\left|\\psi\\right\\rangle = \\alpha\\left|0\\right\\rangle + \\beta \\left|1\\right\\rangle$$\n",
    "\n",
    "\n",
    "where $\\alpha$ and $\\beta$ are complex numbers. In a measurement the probability of the bit being in $\\left|0\\right\\rangle$ is $|\\alpha|^2$ and $\\left|1\\right\\rangle$ is $|\\beta|^2$. As a vector this is\n",
    "\n",
    "$$\n",
    "\\left|\\psi\\right\\rangle =  \n",
    "\\begin{pmatrix}\n",
    "\\alpha \\\\\n",
    "\\beta\n",
    "\\end{pmatrix}.\n",
    "$$\n",
    "\n",
    "Note due to conservation probability $|\\alpha|^2+ |\\beta|^2 = 1$ and since global phase is undetectable $\\left|\\psi\\right\\rangle := e^{i\\delta} \\left|\\psi\\right\\rangle$ we only requires two real numbers to describe a single qubit quantum state.\n",
    "\n",
    "A convenient representation is\n",
    "\n",
    "$$\\left|\\psi\\right\\rangle = \\cos(\\theta/2)\\left|0\\right\\rangle + \\sin(\\theta/2)e^{i\\phi}\\left|1\\right\\rangle$$\n",
    "\n",
    "where $0\\leq \\phi < 2\\pi$, and $0\\leq \\theta \\leq \\pi$.  From this it is clear that there is a one-to-one correspondence between qubit states ($\\mathbb{C}^2$) and the points on the surface of a unit sphere ($\\mathbb{R}^3$). This is called the Bloch sphere representation of a qubit state.\n",
    "\n",
    "Quantum gates/operations are usually represented as matrices. A gate which acts on a qubit is represented by a $2\\times 2$ unitary matrix $U$. The action of the quantum gate is found by multiplying the matrix representing the gate with the vector which represents the quantum state.\n",
    "\n",
    "$$\\left|\\psi'\\right\\rangle = U\\left|\\psi\\right\\rangle$$\n",
    "\n",
    "A general unitary must be able to take the $\\left|0\\right\\rangle$ to the above state. That is \n",
    "\n",
    "$$\n",
    "U = \\begin{pmatrix}\n",
    "\\cos(\\theta/2) & a \\\\\n",
    "e^{i\\phi}\\sin(\\theta/2) & b \n",
    "\\end{pmatrix}\n",
    "$$ \n",
    "\n",
    "where $a$ and $b$ are complex numbers constrained such that $U^\\dagger U = I$ for all $0\\leq\\theta\\leq\\pi$ and $0\\leq \\phi<2\\pi$. This gives 3 constraints and as such $a\\rightarrow -e^{i\\lambda}\\sin(\\theta/2)$ and $b\\rightarrow e^{i\\lambda+i\\phi}\\cos(\\theta/2)$ where $0\\leq \\lambda<2\\pi$ giving \n",
    "\n",
    "$$\n",
    "U = \\begin{pmatrix}\n",
    "\\cos(\\theta/2) & -e^{i\\lambda}\\sin(\\theta/2) \\\\\n",
    "e^{i\\phi}\\sin(\\theta/2) & e^{i\\lambda+i\\phi}\\cos(\\theta/2) \n",
    "\\end{pmatrix}.\n",
    "$$\n",
    "\n",
    "This is the most general form of a single qubit unitary."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Single-Qubit Gates\n",
    "\n",
    "The single-qubit gates available are:\n",
    "- u gates\n",
    "- Identity gate\n",
    "- Pauli gates\n",
    "- Clifford gates\n",
    "- $C3$ gates\n",
    "- Standard rotation gates \n",
    "\n",
    "We have provided a backend: `unitary_simulator` to allow you to calculate the unitary matrices. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:24.381507Z",
     "start_time": "2018-09-29T00:15:24.373378Z"
    }
   },
   "outputs": [],
   "source": [
    "q = QuantumRegister(1)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### u gates\n",
    "\n",
    "In Qiskit we give you access to the general unitary using the $u3$ gate\n",
    "\n",
    "$$\n",
    "u3(\\theta, \\phi, \\lambda) = U(\\theta, \\phi, \\lambda) \n",
    "$$\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:25.666961Z",
     "start_time": "2018-09-29T00:15:24.386736Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌──────────────────────────┐\n",
       "q0_0: |0>┤ U3(1.5708,1.5708,1.5708) ├\n",
       "         └──────────────────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c4885f550>"
      ]
     },
     "execution_count": 4,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.u3(pi/2,pi/2,pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:25.686483Z",
     "start_time": "2018-09-29T00:15:25.669083Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 0.707+0.j   ,  0.   -0.707j],\n",
       "       [ 0.   +0.707j, -0.707+0.j   ]])"
      ]
     },
     "execution_count": 5,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "The $u2(\\phi, \\lambda) =u3(\\pi/2, \\phi, \\lambda)$ has the matrix form\n",
    "\n",
    "$$\n",
    "u2(\\phi, \\lambda) = \n",
    "\\frac{1}{\\sqrt{2}} \\begin{pmatrix}\n",
    "1 & -e^{i\\lambda} \\\\\n",
    "e^{i\\phi} & e^{i(\\phi + \\lambda)}\n",
    "\\end{pmatrix}.\n",
    "$$\n",
    "\n",
    "This is a useful gate as it allows us to create superpositions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:26.803656Z",
     "start_time": "2018-09-29T00:15:25.688915Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───────────────────┐\n",
       "q0_0: |0>┤ U2(1.5708,1.5708) ├\n",
       "         └───────────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c70902b70>"
      ]
     },
     "execution_count": 6,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.u2(pi/2,pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:26.820459Z",
     "start_time": "2018-09-29T00:15:26.805575Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 0.707+0.j   ,  0.   -0.707j],\n",
       "       [ 0.   +0.707j, -0.707+0.j   ]])"
      ]
     },
     "execution_count": 7,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "The $u1(\\lambda)= u3(0, 0, \\lambda)$ gate has the matrix form\n",
    "\n",
    "$$\n",
    "u1(\\lambda) = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 \\\\\n",
    "0 & e^{i \\lambda}\n",
    "\\end{pmatrix},\n",
    "$$\n",
    "\n",
    "which is a useful as it allows us to apply a quantum phase."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:27.935053Z",
     "start_time": "2018-09-29T00:15:26.822215Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌────────────┐\n",
       "q0_0: |0>┤ U1(1.5708) ├\n",
       "         └────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c719732b0>"
      ]
     },
     "execution_count": 8,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.u1(pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:27.964213Z",
     "start_time": "2018-09-29T00:15:27.940835Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+1.j]])"
      ]
     },
     "execution_count": 9,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "The $u0(\\delta)= u3(0, 0, 0)$ gate is the identity matrix. It has the matrix form\n",
    "\n",
    "$$\n",
    "u0(\\delta) = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 \\\\\n",
    "0 & 1\n",
    "\\end{pmatrix}.\n",
    "$$\n",
    "\n",
    "The identity gate does nothing (but can add noise in the real device for a period of time equal to fractions of the single qubit gate time)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 10,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:29.040953Z",
     "start_time": "2018-09-29T00:15:27.968687Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌────────────┐\n",
       "q0_0: |0>┤ U0(1.5708) ├\n",
       "         └────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c709365f8>"
      ]
     },
     "execution_count": 10,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.u0(pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 11,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:29.059033Z",
     "start_time": "2018-09-29T00:15:29.043032Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j]])"
      ]
     },
     "execution_count": 11,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Identity gate\n",
    "\n",
    "The identity gate is $Id = u0(1)$."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 12,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:30.125226Z",
     "start_time": "2018-09-29T00:15:29.062116Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌────┐\n",
       "q0_0: |0>┤ Id ├\n",
       "         └────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c71976278>"
      ]
     },
     "execution_count": 12,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.iden(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 13,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:30.140784Z",
     "start_time": "2018-09-29T00:15:30.127428Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j]])"
      ]
     },
     "execution_count": 13,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Pauli gates\n",
    "\n",
    "#### $X$: bit-flip gate\n",
    "\n",
    "The bit-flip gate $X$ is defined as:\n",
    "\n",
    "$$\n",
    "X   =  \n",
    "\\begin{pmatrix}\n",
    "0 & 1\\\\\n",
    "1 & 0\n",
    "\\end{pmatrix}= u3(\\pi,0,\\pi)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 14,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:31.251259Z",
     "start_time": "2018-09-29T00:15:30.142518Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐\n",
       "q0_0: |0>┤ X ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c70936860>"
      ]
     },
     "execution_count": 14,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.x(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 15,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:31.268863Z",
     "start_time": "2018-09-29T00:15:31.253685Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[0.+0.j, 1.+0.j],\n",
       "       [1.+0.j, 0.+0.j]])"
      ]
     },
     "execution_count": 15,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### $Y$: bit- and phase-flip gate\n",
    "\n",
    "The $Y$ gate is defined as:\n",
    "\n",
    "$$\n",
    "Y  = \n",
    "\\begin{pmatrix}\n",
    "0 & -i\\\\\n",
    "i & 0\n",
    "\\end{pmatrix}=u3(\\pi,\\pi/2,\\pi/2)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 16,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:32.367457Z",
     "start_time": "2018-09-29T00:15:31.270412Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐\n",
       "q0_0: |0>┤ Y ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c71976630>"
      ]
     },
     "execution_count": 16,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.y(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 17,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:33.152683Z",
     "start_time": "2018-09-29T00:15:32.369796Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[0.+0.j, 0.-1.j],\n",
       "       [0.+1.j, 0.+0.j]])"
      ]
     },
     "execution_count": 17,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### $Z$: phase-flip gate\n",
    "\n",
    "The phase flip gate $Z$ is defined as:\n",
    "\n",
    "$$\n",
    "Z = \n",
    "\\begin{pmatrix}\n",
    "1 & 0\\\\\n",
    "0 & -1\n",
    "\\end{pmatrix}=u1(\\pi)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 18,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:34.348628Z",
     "start_time": "2018-09-29T00:15:33.158278Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐\n",
       "q0_0: |0>┤ Z ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c718faeb8>"
      ]
     },
     "execution_count": 18,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.z(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 19,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:34.367128Z",
     "start_time": "2018-09-29T00:15:34.350725Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 1.+0.j,  0.+0.j],\n",
       "       [ 0.+0.j, -1.+0.j]])"
      ]
     },
     "execution_count": 19,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Clifford gates\n",
    "\n",
    "#### Hadamard gate\n",
    "\n",
    "$$\n",
    "H = \n",
    "\\frac{1}{\\sqrt{2}}\n",
    "\\begin{pmatrix}\n",
    "1 & 1\\\\\n",
    "1 & -1\n",
    "\\end{pmatrix}= u2(0,\\pi)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 20,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:35.530446Z",
     "start_time": "2018-09-29T00:15:34.368793Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐\n",
       "q0_0: |0>┤ H ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c71966438>"
      ]
     },
     "execution_count": 20,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.h(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 21,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:35.550723Z",
     "start_time": "2018-09-29T00:15:35.532971Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 0.707+0.j,  0.707+0.j],\n",
       "       [ 0.707+0.j, -0.707+0.j]])"
      ]
     },
     "execution_count": 21,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### $S$ (or, $\\sqrt{Z}$ phase) gate\n",
    "\n",
    "$$\n",
    "S = \n",
    "\\begin{pmatrix}\n",
    "1 & 0\\\\\n",
    "0 & i\n",
    "\\end{pmatrix}= u1(\\pi/2)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 22,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:36.627291Z",
     "start_time": "2018-09-29T00:15:35.552841Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐\n",
       "q0_0: |0>┤ S ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717e7588>"
      ]
     },
     "execution_count": 22,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.s(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 23,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:36.661217Z",
     "start_time": "2018-09-29T00:15:36.631382Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+1.j]])"
      ]
     },
     "execution_count": 23,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### $S^{\\dagger}$ (or, conjugate of $\\sqrt{Z}$ phase) gate\n",
    "\n",
    "$$\n",
    "S^{\\dagger} = \n",
    "\\begin{pmatrix}\n",
    "1 & 0\\\\\n",
    "0 & -i\n",
    "\\end{pmatrix}= u1(-\\pi/2)\n",
    "$$\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 24,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:37.965580Z",
     "start_time": "2018-09-29T00:15:36.668521Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌─────┐\n",
       "q0_0: |0>┤ Sdg ├\n",
       "         └─────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c71973a20>"
      ]
     },
     "execution_count": 24,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.sdg(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 25,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:37.995581Z",
     "start_time": "2018-09-29T00:15:37.968281Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.-1.j]])"
      ]
     },
     "execution_count": 25,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### $C3$ gates\n",
    "#### $T$ (or, $\\sqrt{S}$ phase) gate\n",
    "\n",
    "$$\n",
    "T = \n",
    "\\begin{pmatrix}\n",
    "1 & 0\\\\\n",
    "0 & e^{i \\pi/4}\n",
    "\\end{pmatrix}= u1(\\pi/4) \n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 26,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:39.268078Z",
     "start_time": "2018-09-29T00:15:38.005726Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐\n",
       "q0_0: |0>┤ T ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717f1320>"
      ]
     },
     "execution_count": 26,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.t(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 27,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:39.285757Z",
     "start_time": "2018-09-29T00:15:39.270165Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.   +0.j   , 0.   +0.j   ],\n",
       "       [0.   +0.j   , 0.707+0.707j]])"
      ]
     },
     "execution_count": 27,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### $T^{\\dagger}$ (or, conjugate of $\\sqrt{S}$ phase) gate\n",
    "\n",
    "$$\n",
    "T^{\\dagger} =  \n",
    "\\begin{pmatrix}\n",
    "1 & 0\\\\\n",
    "0 & e^{-i \\pi/4}\n",
    "\\end{pmatrix}= u1(-pi/4)\n",
    "$$\n",
    "\n",
    "They can be added as below."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 28,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:40.466163Z",
     "start_time": "2018-09-29T00:15:39.287535Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌─────┐\n",
       "q0_0: |0>┤ Tdg ├\n",
       "         └─────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c718faac8>"
      ]
     },
     "execution_count": 28,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.tdg(q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 29,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:40.500673Z",
     "start_time": "2018-09-29T00:15:40.468194Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.   +0.j   , 0.   +0.j   ],\n",
       "       [0.   +0.j   , 0.707-0.707j]])"
      ]
     },
     "execution_count": 29,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Standard Rotations\n",
    "\n",
    "The standard rotation gates are those that define rotations around the Paulis $P=\\{X,Y,Z\\}$. They are defined as \n",
    "\n",
    "$$ R_P(\\theta) = \\exp(-i \\theta P/2) = \\cos(\\theta/2)I -i \\sin(\\theta/2)P$$\n",
    "\n",
    "#### Rotation around X-axis\n",
    "\n",
    "$$\n",
    "R_x(\\theta) = \n",
    "\\begin{pmatrix}\n",
    "\\cos(\\theta/2) & -i\\sin(\\theta/2)\\\\\n",
    "-i\\sin(\\theta/2) & \\cos(\\theta/2)\n",
    "\\end{pmatrix} = u3(\\theta, -\\pi/2,\\pi/2)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 30,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:41.848889Z",
     "start_time": "2018-09-29T00:15:40.504414Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌────────────┐\n",
       "q0_0: |0>┤ Rx(1.5708) ├\n",
       "         └────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717f1630>"
      ]
     },
     "execution_count": 30,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.rx(pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 31,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:41.870040Z",
     "start_time": "2018-09-29T00:15:41.850897Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[0.707+0.j   , 0.   -0.707j],\n",
       "       [0.   -0.707j, 0.707+0.j   ]])"
      ]
     },
     "execution_count": 31,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### Rotation around Y-axis\n",
    "\n",
    "$$\n",
    "R_y(\\theta) =\n",
    "\\begin{pmatrix}\n",
    "\\cos(\\theta/2) & - \\sin(\\theta/2)\\\\\n",
    "\\sin(\\theta/2) & \\cos(\\theta/2).\n",
    "\\end{pmatrix} =u3(\\theta,0,0)\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 32,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:42.977649Z",
     "start_time": "2018-09-29T00:15:41.873513Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌────────────┐\n",
       "q0_0: |0>┤ Ry(1.5708) ├\n",
       "         └────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717e7080>"
      ]
     },
     "execution_count": 32,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.ry(pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 33,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:42.996374Z",
     "start_time": "2018-09-29T00:15:42.980438Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 0.707+0.j, -0.707+0.j],\n",
       "       [ 0.707+0.j,  0.707+0.j]])"
      ]
     },
     "execution_count": 33,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### Rotation around Z-axis\n",
    "\n",
    "$$\n",
    "R_z(\\phi) = \n",
    "\\begin{pmatrix}\n",
    "e^{-i \\phi/2} & 0 \\\\\n",
    "0 & e^{i \\phi/2}\n",
    "\\end{pmatrix}\\equiv u1(\\phi)\n",
    "$$\n",
    "\n",
    "Note here we have used an equivalent as is different to u1 by global phase $e^{-i \\phi/2}$."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 34,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:44.157100Z",
     "start_time": "2018-09-29T00:15:42.998031Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌────────────┐\n",
       "q0_0: |0>┤ Rz(1.5708) ├\n",
       "         └────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717f1f60>"
      ]
     },
     "execution_count": 34,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.rz(pi/2,q)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 35,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:44.179782Z",
     "start_time": "2018-09-29T00:15:44.159445Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+1.j]])"
      ]
     },
     "execution_count": 35,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Note this is different due only to a global phase"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Multi-Qubit Gates\n",
    "\n",
    "### Mathematical Preliminaries\n",
    "\n",
    "The space of quantum computer grows exponential with the number of qubits. For $n$ qubits the complex vector space has dimensions $d=2^n$. To describe states of a multi-qubit system, the tensor product is used to \"glue together\" operators and basis vectors.\n",
    "\n",
    "Let's start by considering a 2-qubit system. Given two operators $A$ and $B$ that each act on one qubit, the joint operator $A \\otimes B$ acting on two qubits is\n",
    "\n",
    "$$\\begin{equation}\n",
    "\tA\\otimes B = \n",
    "\t\\begin{pmatrix} \n",
    "\t\tA_{00} \\begin{pmatrix} \n",
    "\t\t\tB_{00} & B_{01} \\\\\n",
    "\t\t\tB_{10} & B_{11}\n",
    "\t\t\\end{pmatrix} & A_{01} \t\\begin{pmatrix} \n",
    "\t\t\t\tB_{00} & B_{01} \\\\\n",
    "\t\t\t\tB_{10} & B_{11}\n",
    "\t\t\t\\end{pmatrix} \\\\\n",
    "\t\tA_{10} \t\\begin{pmatrix} \n",
    "\t\t\t\t\tB_{00} & B_{01} \\\\\n",
    "\t\t\t\t\tB_{10} & B_{11}\n",
    "\t\t\t\t\\end{pmatrix} & A_{11} \t\\begin{pmatrix} \n",
    "\t\t\t\t\t\t\tB_{00} & B_{01} \\\\\n",
    "\t\t\t\t\t\t\tB_{10} & B_{11}\n",
    "\t\t\t\t\t\t\\end{pmatrix}\n",
    "\t\\end{pmatrix},\t\t\t\t\t\t\n",
    "\\end{equation}$$\n",
    "\n",
    "where $A_{jk}$ and $B_{lm}$ are the matrix elements of $A$ and $B$, respectively.\n",
    "\n",
    "Analogously, the basis vectors for the 2-qubit system are formed using the tensor product of basis vectors for a single qubit:\n",
    "$$\\begin{equation}\\begin{split}\n",
    "\t\\left|{00}\\right\\rangle &= \\begin{pmatrix} \n",
    "\t\t1 \\begin{pmatrix} \n",
    "\t\t\t1  \\\\\n",
    "\t\t\t0\n",
    "\t\t\\end{pmatrix} \\\\\n",
    "\t\t0 \\begin{pmatrix} \n",
    "\t\t\t1  \\\\\n",
    "\t\t\t0 \n",
    "\t\t\\end{pmatrix}\n",
    "\t\\end{pmatrix} = \\begin{pmatrix} 1 \\\\ 0 \\\\ 0 \\\\0 \\end{pmatrix}~~~\\left|{01}\\right\\rangle = \\begin{pmatrix} \n",
    "\t1 \\begin{pmatrix} \n",
    "\t0 \\\\\n",
    "\t1\n",
    "\t\\end{pmatrix} \\\\\n",
    "\t0 \\begin{pmatrix} \n",
    "\t0  \\\\\n",
    "\t1 \n",
    "\t\\end{pmatrix}\n",
    "\t\\end{pmatrix} = \\begin{pmatrix}0 \\\\ 1 \\\\ 0 \\\\ 0 \\end{pmatrix}\\end{split}\n",
    "\\end{equation}$$\n",
    "    \n",
    "$$\\begin{equation}\\begin{split}\\left|{10}\\right\\rangle = \\begin{pmatrix} \n",
    "\t0\\begin{pmatrix} \n",
    "\t1  \\\\\n",
    "\t0\n",
    "\t\\end{pmatrix} \\\\\n",
    "\t1\\begin{pmatrix} \n",
    "\t1 \\\\\n",
    "\t0 \n",
    "\t\\end{pmatrix}\n",
    "\t\\end{pmatrix} = \\begin{pmatrix} 0 \\\\ 0 \\\\ 1 \\\\ 0 \\end{pmatrix}~~~ \t\\left|{11}\\right\\rangle = \\begin{pmatrix} \n",
    "\t0 \\begin{pmatrix} \n",
    "\t0  \\\\\n",
    "\t1\n",
    "\t\\end{pmatrix} \\\\\n",
    "\t1\\begin{pmatrix} \n",
    "\t0  \\\\\n",
    "\t1 \n",
    "\t\\end{pmatrix}\n",
    "\t\\end{pmatrix} = \\begin{pmatrix} 0 \\\\ 0 \\\\ 0 \\\\1 \\end{pmatrix}\\end{split}\n",
    "\\end{equation}.$$\n",
    "\n",
    "Note we've introduced a shorthand for the tensor product of basis vectors, wherein $\\left|0\\right\\rangle \\otimes \\left|0\\right\\rangle$ is written as $\\left|00\\right\\rangle$. The state of an $n$-qubit system can described using the $n$-fold tensor product of single-qubit basis vectors. Notice that the basis vectors for a 2-qubit system are 4-dimensional; in general, the basis vectors of an $n$-qubit sytsem are $2^{n}$-dimensional, as noted earlier.\n",
    "\n",
    "### Basis vector ordering in Qiskit\n",
    "\n",
    "Within the physics community, the qubits of a multi-qubit systems are typically ordered with the first qubit on the left-most side of the tensor product and the last qubit on the right-most side. For instance, if the first qubit is in state $\\left|0\\right\\rangle$ and second is in state $\\left|1\\right\\rangle$, their joint state would be $\\left|01\\right\\rangle$. Qiskit uses a slightly different ordering of the qubits, in which the qubits are represented from the most significant bit (MSB) on the left to the least significant bit (LSB) on the right (big-endian). This is similar to bitstring representation on classical computers, and enables easy conversion from bitstrings to integers after measurements are performed. For the example just given, the joint state would be represented as $\\left|10\\right\\rangle$. Importantly, _this change in the representation of multi-qubit states affects the way multi-qubit gates are represented in Qiskit_, as discussed below.\n",
    "\n",
    "The representation used in Qiskit enumerates the basis vectors in increasing order of the integers they represent. For instance, the basis vectors for a 2-qubit system would be ordered as $\\left|00\\right\\rangle$, $\\left|01\\right\\rangle$, $\\left|10\\right\\rangle$, and $\\left|11\\right\\rangle$. Thinking of the basis vectors as bit strings, they encode the integers 0,1,2 and 3, respectively.\n",
    "\n",
    "\n",
    "### Controlled operations on qubits\n",
    "\n",
    "A common multi-qubit gate involves the application of a gate to one qubit, conditioned on the state of another qubit. For instance, we might want to flip the state of the second qubit when the first qubit is in $\\left|0\\right\\rangle$. Such gates are known as _controlled gates_. The standard multi-qubit gates consist of two-qubit gates and three-qubit gates. The two-qubit gates are:\n",
    "- controlled Pauli gates\n",
    "- controlled Hadamard gate\n",
    "- controlled rotation gates\n",
    "- controlled phase gate\n",
    "- controlled u3 gate\n",
    "- swap gate\n",
    "\n",
    "The three-qubit gates are: \n",
    "- Toffoli gate \n",
    "- Fredkin gate"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Two-qubit gates\n",
    "\n",
    "Most of the two-gates are of the controlled type (the SWAP gate being the exception). In general, a controlled two-qubit gate $C_{U}$ acts to apply the single-qubit unitary $U$ to the second qubit when the state of the first qubit is in $\\left|1\\right\\rangle$. Suppose $U$ has a matrix representation\n",
    "\n",
    "$$U = \\begin{pmatrix} u_{00} & u_{01} \\\\ u_{10} & u_{11}\\end{pmatrix}.$$\n",
    "\n",
    "We can work out the action of $C_{U}$ as follows. Recall that the basis vectors for a two-qubit system are ordered as $\\left|00\\right\\rangle, \\left|01\\right\\rangle, \\left|10\\right\\rangle, \\left|11\\right\\rangle$. Suppose the **control qubit** is **qubit 0** (which, according to Qiskit's convention, is one the _right-hand_ side of the tensor product). If the control qubit is in $\\left|1\\right\\rangle$, $U$ should be applied to the **target** (qubit 1, on the _left-hand_ side of the tensor product). Therefore, under the action of $C_{U}$, the basis vectors are transformed according to\n",
    "\n",
    "$$\\begin{align*}\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle}\\\\\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{U\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle}\\\\\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle}\\\\\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{U\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle}\\\\\n",
    "\\end{align*}.$$\n",
    "\n",
    "In matrix form, the action of $C_{U}$ is\n",
    "\n",
    "$$\\begin{equation}\n",
    "\tC_U = \\begin{pmatrix}\n",
    "\t1 & 0 & 0 & 0 \\\\\n",
    "\t0 & u_{00} & 0 & u_{01} \\\\\n",
    "\t0 & 0 & 1 & 0 \\\\\n",
    "\t0 & u_{10} &0 & u_{11}\n",
    "\t\t\\end{pmatrix}.\n",
    "\\end{equation}$$\n",
    "\n",
    "To work out these matrix elements, let\n",
    "\n",
    "$$C_{(jk), (lm)} = \\left(\\underset{\\text{qubit}~1}{\\left\\langle j \\right|} \\otimes \\underset{\\text{qubit}~0}{\\left\\langle k \\right|}\\right) C_{U} \\left(\\underset{\\text{qubit}~1}{\\left| l \\right\\rangle} \\otimes \\underset{\\text{qubit}~0}{\\left| k \\right\\rangle}\\right),$$\n",
    "\n",
    "compute the action of $C_{U}$ (given above), and compute the inner products.\n",
    "\n",
    "As shown in the examples below, this operation is implemented in Qiskit as `cU(q[0],q[1])`.\n",
    "\n",
    "\n",
    "If **qubit 1 is the control and qubit 0 is the target**, then the basis vectors are transformed according to\n",
    "$$\\begin{align*}\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle}\\\\\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{\\left|0\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle}\\\\\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|0\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{U\\left|0\\right\\rangle}\\\\\n",
    "C_{U}: \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{\\left|1\\right\\rangle} &\\rightarrow \\underset{\\text{qubit}~1}{\\left|1\\right\\rangle}\\otimes \\underset{\\text{qubit}~0}{U\\left|1\\right\\rangle}\\\\\n",
    "\\end{align*},$$\n",
    "\n",
    "\n",
    "which implies the matrix form of $C_{U}$ is\n",
    "$$\\begin{equation}\n",
    "\tC_U = \\begin{pmatrix}\n",
    "\t1 & 0 & 0  & 0 \\\\\n",
    "\t0 & 1 & 0 & 0 \\\\\n",
    "\t0 & 0 & u_{00} & u_{01} \\\\\n",
    "\t0 & 0 & u_{10} & u_{11}\n",
    "\t\t\\end{pmatrix}.\n",
    "\\end{equation}$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 36,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:44.186355Z",
     "start_time": "2018-09-29T00:15:44.182554Z"
    }
   },
   "outputs": [],
   "source": [
    "q = QuantumRegister(2)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Controlled Pauli Gates\n",
    "\n",
    "#### Controlled-X (or, controlled-NOT) gate\n",
    "The controlled-not gate flips the `target` qubit when the control qubit is in the state $\\left|1\\right\\rangle$. If we take the MSB as the control qubit (e.g. `cx(q[1],q[0])`), then the matrix would look like\n",
    "\n",
    "$$\n",
    "C_X = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 1\\\\\n",
    "0 & 0 & 1 & 0\n",
    "\\end{pmatrix}. \n",
    "$$\n",
    "\n",
    "However, when the LSB is the control qubit, (e.g. `cx(q[0],q[1])`), this gate is equivalent to the following matrix:\n",
    "\n",
    "$$\n",
    "C_X = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 1\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & 1 & 0 & 0\n",
    "\\end{pmatrix}. \n",
    "$$\n",
    "\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 37,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:45.529617Z",
     "start_time": "2018-09-29T00:15:44.189643Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">              \n",
       "q1_0: |0>──■──\n",
       "         ┌─┴─┐\n",
       "q1_1: |0>┤ X ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717e76d8>"
      ]
     },
     "execution_count": 37,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.cx(q[0],q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 38,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:45.546415Z",
     "start_time": "2018-09-29T00:15:45.531833Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j]])"
      ]
     },
     "execution_count": 38,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### Controlled $Y$ gate\n",
    "\n",
    "Apply the $Y$ gate to the target qubit if the control qubit is the MSB\n",
    "\n",
    "$$\n",
    "C_Y = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 0 & -i\\\\\n",
    "0 & 0 & i & 0\n",
    "\\end{pmatrix},\n",
    "$$\n",
    "\n",
    "or when the LSB is the control\n",
    "\n",
    "$$\n",
    "C_Y = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & -i\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & i & 0 & 0\n",
    "\\end{pmatrix}.\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 39,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:46.767098Z",
     "start_time": "2018-09-29T00:15:45.549354Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">              \n",
       "q1_0: |0>──■──\n",
       "         ┌─┴─┐\n",
       "q1_1: |0>┤ Y ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717fb0f0>"
      ]
     },
     "execution_count": 39,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.cy(q[0],q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 40,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:46.788301Z",
     "start_time": "2018-09-29T00:15:46.769145Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.-1.j],\n",
       "       [0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+1.j, 0.+0.j, 0.+0.j]])"
      ]
     },
     "execution_count": 40,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### Controlled $Z$ (or, controlled Phase) gate\n",
    "\n",
    "Similarly, the controlled Z gate flips the phase of the target qubit if the control qubit is $\\left|1\\right\\rangle$. The matrix looks the same regardless of whether the MSB or LSB is the control qubit:\n",
    "\n",
    "$$\n",
    "C_Z = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & 0 & 0 & -1\n",
    "\\end{pmatrix}\n",
    "$$\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 41,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:47.989274Z",
     "start_time": "2018-09-29T00:15:46.791557Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">            \n",
       "q1_0: |0>─■─\n",
       "          │ \n",
       "q1_1: |0>─■─\n",
       "            </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c718fa0f0>"
      ]
     },
     "execution_count": 41,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.cz(q[0],q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 42,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:48.017523Z",
     "start_time": "2018-09-29T00:15:47.991182Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 1.+0.j,  0.+0.j,  0.+0.j,  0.+0.j],\n",
       "       [ 0.+0.j,  1.+0.j,  0.+0.j,  0.+0.j],\n",
       "       [ 0.+0.j,  0.+0.j,  1.+0.j,  0.+0.j],\n",
       "       [ 0.+0.j,  0.+0.j,  0.+0.j, -1.+0.j]])"
      ]
     },
     "execution_count": 42,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Controlled Hadamard gate\n",
    "\n",
    "Apply $H$ gate to the target qubit if the control qubit is $\\left|1\\right\\rangle$. Below is the case where the control is the LSB qubit.\n",
    "\n",
    "$$\n",
    "C_H = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & \\frac{1}{\\sqrt{2}} & 0 & \\frac{1}{\\sqrt{2}}\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & \\frac{1}{\\sqrt{2}}  & 0& -\\frac{1}{\\sqrt{2}}\n",
    "\\end{pmatrix}\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 43,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:49.150237Z",
     "start_time": "2018-09-29T00:15:48.019326Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">              \n",
       "q1_0: |0>──■──\n",
       "         ┌─┴─┐\n",
       "q1_1: |0>┤ H ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717fb5c0>"
      ]
     },
     "execution_count": 43,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.ch(q[0],q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 44,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:49.184874Z",
     "start_time": "2018-09-29T00:15:49.152802Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 0.707+0.707j,  0.   +0.j   ,  0.   +0.j   ,  0.   +0.j   ],\n",
       "       [ 0.   +0.j   ,  0.5  +0.5j  ,  0.   +0.j   ,  0.5  +0.5j  ],\n",
       "       [ 0.   +0.j   ,  0.   +0.j   ,  0.707+0.707j,  0.   +0.j   ],\n",
       "       [ 0.   +0.j   ,  0.5  +0.5j  ,  0.   +0.j   , -0.5  -0.5j  ]])"
      ]
     },
     "execution_count": 44,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Controlled rotation gates\n",
    "\n",
    "#### Controlled rotation around Z-axis\n",
    "\n",
    "Perform rotation around Z-axis on the target qubit if the control qubit (here LSB) is $\\left|1\\right\\rangle$.\n",
    "\n",
    "$$\n",
    "C_{Rz}(\\lambda) = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & e^{-i\\lambda/2} & 0 & 0\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & 0 & 0 & e^{i\\lambda/2}\n",
    "\\end{pmatrix}\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 45,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:50.307303Z",
     "start_time": "2018-09-29T00:15:49.188784Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">                       \n",
       "q1_0: |0>──────■───────\n",
       "         ┌─────┴──────┐\n",
       "q1_1: |0>┤ Rz(1.5708) ├\n",
       "         └────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c7180a160>"
      ]
     },
     "execution_count": 45,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.crz(pi/2,q[0],q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 46,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:50.327982Z",
     "start_time": "2018-09-29T00:15:50.310167Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.   +0.j   , 0.   +0.j   , 0.   +0.j   , 0.   +0.j   ],\n",
       "       [0.   +0.j   , 0.707-0.707j, 0.   +0.j   , 0.   +0.j   ],\n",
       "       [0.   +0.j   , 0.   +0.j   , 1.   +0.j   , 0.   +0.j   ],\n",
       "       [0.   +0.j   , 0.   +0.j   , 0.   +0.j   , 0.707+0.707j]])"
      ]
     },
     "execution_count": 46,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Controlled phase rotation\n",
    "\n",
    "Perform a phase rotation if both qubits are in the $\\left|11\\right\\rangle$ state. The matrix looks the same regardless of whether the MSB or LSB is the control qubit.\n",
    "\n",
    "$$\n",
    "C_{u1}(\\lambda) = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & 0 & 0 & e^{i\\lambda}\n",
    "\\end{pmatrix}\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 47,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:51.580519Z",
     "start_time": "2018-09-29T00:15:50.329669Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">                  \n",
       "q1_0: |0>─■───────\n",
       "          │1.5708 \n",
       "q1_1: |0>─■───────\n",
       "                  </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717f1160>"
      ]
     },
     "execution_count": 47,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.cu1(pi/2,q[0], q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 48,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:51.608625Z",
     "start_time": "2018-09-29T00:15:51.583186Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+1.j]])"
      ]
     },
     "execution_count": 48,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Controlled $u3$ rotation\n",
    "\n",
    "Perform controlled-$u3$ rotation on the target qubit if the control qubit (here LSB) is $\\left|1\\right\\rangle$. \n",
    "\n",
    "$$\n",
    "C_{u3}(\\theta, \\phi, \\lambda) \\equiv \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & e^{-i(\\phi+\\lambda)/2}\\cos(\\theta/2) & 0 & -e^{-i(\\phi-\\lambda)/2}\\sin(\\theta/2)\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & e^{i(\\phi-\\lambda)/2}\\sin(\\theta/2) & 0 & e^{i(\\phi+\\lambda)/2}\\cos(\\theta/2)\n",
    "\\end{pmatrix}.\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 49,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:52.853130Z",
     "start_time": "2018-09-29T00:15:51.610840Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">                                     \n",
       "q1_0: |0>─────────────■──────────────\n",
       "         ┌────────────┴─────────────┐\n",
       "q1_1: |0>┤ U3(1.5708,1.5708,1.5708) ├\n",
       "         └──────────────────────────┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717f1128>"
      ]
     },
     "execution_count": 49,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.cu3(pi/2, pi/2, pi/2, q[0], q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 50,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:52.874428Z",
     "start_time": "2018-09-29T00:15:52.855187Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[ 1.   +0.j   ,  0.   +0.j   ,  0.   +0.j   ,  0.   +0.j   ],\n",
       "       [ 0.   +0.j   ,  0.   -0.707j,  0.   +0.j   , -0.707+0.j   ],\n",
       "       [ 0.   +0.j   ,  0.   +0.j   ,  1.   +0.j   ,  0.   +0.j   ],\n",
       "       [ 0.   +0.j   ,  0.707+0.j   ,  0.   +0.j   ,  0.   +0.707j]])"
      ]
     },
     "execution_count": 50,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### SWAP gate\n",
    "\n",
    "The SWAP gate exchanges the two qubits. It transforms the basis vectors as\n",
    "\n",
    "$$\\left|00\\right\\rangle \\rightarrow \\left|00\\right\\rangle~,~\\left|01\\right\\rangle \\rightarrow \\left|10\\right\\rangle~,~\\left|10\\right\\rangle \\rightarrow \\left|01\\right\\rangle~,~\\left|11\\right\\rangle \\rightarrow \\left|11\\right\\rangle,$$\n",
    "\n",
    "which gives a matrix representation of the form\n",
    "\n",
    "$$\n",
    "\\mathrm{SWAP} = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 1 & 0\\\\\n",
    "0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 1\n",
    "\\end{pmatrix}.\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 51,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:54.104384Z",
     "start_time": "2018-09-29T00:15:52.877953Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">            \n",
       "q1_0: |0>─X─\n",
       "          │ \n",
       "q1_1: |0>─X─\n",
       "            </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c7180ab38>"
      ]
     },
     "execution_count": 51,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.swap(q[0], q[1])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 52,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:54.123272Z",
     "start_time": "2018-09-29T00:15:54.106315Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j]])"
      ]
     },
     "execution_count": 52,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Three-qubit gates\n",
    "\n",
    "\n",
    "There are two commonly-used three-qubit gates. For three qubits, the basis vectors are ordered as\n",
    "\n",
    "$$\\left|000\\right\\rangle, \\left|001\\right\\rangle, \\left|010\\right\\rangle, \\left|011\\right\\rangle, \\left|100\\right\\rangle, \\left|101\\right\\rangle, \\left|110\\right\\rangle, \\left|111\\right\\rangle,$$\n",
    "\n",
    "which, as bitstrings, represent the integers $0,1,2,\\cdots, 7$. Again, Qiskit uses a representation in which the first qubit is on the right-most side of the tensor product and the third qubit is on the left-most side:\n",
    "\n",
    "$$\\left|abc\\right\\rangle : \\underset{\\text{qubit 2}}{\\left|a\\right\\rangle}\\otimes \\underset{\\text{qubit 1}}{\\left|b\\right\\rangle}\\otimes \\underset{\\text{qubit 0}}{\\left|c\\right\\rangle}.$$"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Toffoli gate ($ccx$ gate)\n",
    "\n",
    "The [Toffoli gate](https://en.wikipedia.org/wiki/Quantum_logic_gate#Toffoli_(CCNOT)_gate) flips the third qubit if the first two qubits (LSB) are both $\\left|1\\right\\rangle$:\n",
    "\n",
    "$$\\left|abc\\right\\rangle \\rightarrow \\left|bc\\oplus a\\right\\rangle \\otimes \\left|b\\right\\rangle \\otimes \\left|c\\right\\rangle.$$\n",
    "\n",
    "In matrix form, the Toffoli gate is\n",
    "$$\n",
    "C_{CX} = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 1 & 0 & 0 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 1 & 0 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 0 & 0 & 0 & 1\\\\\n",
    "0 & 0 & 0 & 0 & 1 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 0 & 0 & 1 & 0\\\\\n",
    "0 & 0 & 0 & 1 & 0 & 0 & 0 & 0\n",
    "\\end{pmatrix}.\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 53,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:54.132975Z",
     "start_time": "2018-09-29T00:15:54.127056Z"
    }
   },
   "outputs": [],
   "source": [
    "q = QuantumRegister(3)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 54,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:55.291905Z",
     "start_time": "2018-09-29T00:15:54.136934Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">              \n",
       "q2_0: |0>──■──\n",
       "           │  \n",
       "q2_1: |0>──■──\n",
       "         ┌─┴─┐\n",
       "q2_2: |0>┤ X ├\n",
       "         └───┘</pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c7180a470>"
      ]
     },
     "execution_count": 54,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.ccx(q[0], q[1], q[2])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 55,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:55.321561Z",
     "start_time": "2018-09-29T00:15:55.294193Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j]])"
      ]
     },
     "execution_count": 55,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Controlled swap gate (Fredkin Gate)\n",
    "\n",
    "The [Fredkin gate](https://en.wikipedia.org/wiki/Quantum_logic_gate#Fredkin_(CSWAP)_gate), or the _controlled swap gate_, exchanges the second and third qubits if the first qubit (LSB) is $\\left|1\\right\\rangle$:\n",
    "\n",
    "$$ \\left|abc\\right\\rangle \\rightarrow \\begin{cases} \\left|bac\\right\\rangle~~\\text{if}~c=1 \\cr \\left|abc\\right\\rangle~~\\text{if}~c=0 \\end{cases}.$$\n",
    "\n",
    "In matrix form, the Fredkin gate is\n",
    "\n",
    "$$\n",
    "C_{\\mathrm{SWAP}} = \n",
    "\\begin{pmatrix}\n",
    "1 & 0 & 0 & 0 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 1 & 0 & 0 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 1 & 0 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 0 & 1 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 1 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 1 & 0 & 0 & 0 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 0 & 0 & 1 & 0\\\\\n",
    "0 & 0 & 0 & 0 & 0 & 0 & 0 & 1\n",
    "\\end{pmatrix}.\n",
    "$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 56,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:56.767060Z",
     "start_time": "2018-09-29T00:15:55.324346Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">            \n",
       "q2_0: |0>─■─\n",
       "          │ \n",
       "q2_1: |0>─X─\n",
       "          │ \n",
       "q2_2: |0>─X─\n",
       "            </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717fba90>"
      ]
     },
     "execution_count": 56,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q)\n",
    "qc.cswap(q[0], q[1], q[2])\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 57,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:56.852089Z",
     "start_time": "2018-09-29T00:15:56.774963Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([[1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j, 0.+0.j],\n",
       "       [0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 0.+0.j, 1.+0.j]])"
      ]
     },
     "execution_count": 57,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend)\n",
    "job.result().get_unitary(qc, decimals=3)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Non unitary operations\n",
    "\n",
    "Now we have gone through all the unitary operations in quantum circuits we also have access to non-unitary operations. These include measurements, reset of qubits, and classical conditional operations."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 58,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:56.861132Z",
     "start_time": "2018-09-29T00:15:56.856547Z"
    }
   },
   "outputs": [],
   "source": [
    "q = QuantumRegister(1)\n",
    "c = ClassicalRegister(1)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Measurements\n",
    "\n",
    "We don't have access to all the information when we make a measurement in a quantum computer. The quantum state is projected onto the standard basis. Below are two examples showing a circuit that is prepared in a basis state and the quantum computer prepared in a superposition state."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 59,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:58.079872Z",
     "start_time": "2018-09-29T00:15:56.865487Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌─┐\n",
       "q3_0: |0>┤M├\n",
       "         └╥┘\n",
       " c0_0: 0 ═╩═\n",
       "            </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717b2ef0>"
      ]
     },
     "execution_count": 59,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q, c)\n",
    "qc.measure(q, c)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 60,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:58.124389Z",
     "start_time": "2018-09-29T00:15:58.081861Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "{'0': 1024}"
      ]
     },
     "execution_count": 60,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "backend = BasicAer.get_backend('qasm_simulator')\n",
    "job = execute(qc, backend, shots=1024)\n",
    "job.result().get_counts(qc)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    " The simulator predicts that 100 percent of the time the classical register returns 0. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 61,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:59.283582Z",
     "start_time": "2018-09-29T00:15:58.128814Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐┌─┐\n",
       "q3_0: |0>┤ H ├┤M├\n",
       "         └───┘└╥┘\n",
       " c0_0: 0 ══════╩═\n",
       "                 </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c71808cf8>"
      ]
     },
     "execution_count": 61,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q, c)\n",
    "qc.h(q)\n",
    "qc.measure(q, c)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 62,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:15:59.318065Z",
     "start_time": "2018-09-29T00:15:59.286200Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "{'0': 513, '1': 511}"
      ]
     },
     "execution_count": 62,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend, shots=1024)\n",
    "job.result().get_counts(qc)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    " The simulator predicts that 50 percent of the time the classical register returns 0 or 1. "
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Reset\n",
    "It is also possible to `reset` qubits to the $\\left|0\\right\\rangle$ state in the middle of computation. Note that `reset` is not a Gate operation, since it is irreversible."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 63,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:00.676218Z",
     "start_time": "2018-09-29T00:15:59.322345Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">              ┌─┐\n",
       "q3_0: |0>─|0>─┤M├\n",
       "              └╥┘\n",
       " c0_0: 0 ══════╩═\n",
       "                 </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717fbfd0>"
      ]
     },
     "execution_count": 63,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q, c)\n",
    "qc.reset(q[0])\n",
    "qc.measure(q, c)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 64,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:00.760611Z",
     "start_time": "2018-09-29T00:16:00.681669Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "{'0': 1024}"
      ]
     },
     "execution_count": 64,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend, shots=1024)\n",
    "job.result().get_counts(qc)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 65,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:02.094104Z",
     "start_time": "2018-09-29T00:16:00.775977Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐     ┌─┐\n",
       "q3_0: |0>┤ H ├─|0>─┤M├\n",
       "         └───┘     └╥┘\n",
       " c0_0: 0 ═══════════╩═\n",
       "                      </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717b2a58>"
      ]
     },
     "execution_count": 65,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q, c)\n",
    "qc.h(q)\n",
    "qc.reset(q[0])\n",
    "qc.measure(q, c)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 66,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:02.129340Z",
     "start_time": "2018-09-29T00:16:02.096088Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "{'0': 1024}"
      ]
     },
     "execution_count": 66,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend, shots=1024)\n",
    "job.result().get_counts(qc)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Here we see that for both of these circuits the simulator always predicts that the output is 100 percent in the 0 state."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Conditional operations\n",
    "It is also possible to do operations conditioned on the state of the classical register"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 67,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:03.290081Z",
     "start_time": "2018-09-29T00:16:02.133254Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌─────┐┌─┐\n",
       "q3_0: |0>┤  X  ├┤M├\n",
       "         ├──┴──┤└╥┘\n",
       " c0_0: 0 ╡ = 0 ╞═╩═\n",
       "         └─────┘   </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c7198df60>"
      ]
     },
     "execution_count": 67,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q, c)\n",
    "qc.x(q[0]).c_if(c, 0)\n",
    "qc.measure(q,c)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Here the classical bit always takes the value 0 so the qubit state is always flipped. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 68,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "{'1': 1024}"
      ]
     },
     "execution_count": 68,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend, shots=1024)\n",
    "job.result().get_counts(qc)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 69,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:04.406486Z",
     "start_time": "2018-09-29T00:16:03.323686Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<pre style=\"word-wrap: normal;white-space: pre;line-height: 15px;\">         ┌───┐┌─┐┌─────┐┌─┐\n",
       "q3_0: |0>┤ H ├┤M├┤  X  ├┤M├\n",
       "         └───┘└╥┘├──┴──┤└╥┘\n",
       " c0_0: 0 ══════╩═╡ = 0 ╞═╩═\n",
       "                 └─────┘   </pre>"
      ],
      "text/plain": [
       "<qiskit.tools.visualization._text.TextDrawing at 0x7f0c717c6a90>"
      ]
     },
     "execution_count": 69,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "qc = QuantumCircuit(q, c)\n",
    "qc.h(q)\n",
    "qc.measure(q,c)\n",
    "qc.x(q[0]).c_if(c, 0)\n",
    "qc.measure(q,c)\n",
    "qc.draw()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 70,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:04.433578Z",
     "start_time": "2018-09-29T00:16:04.408345Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "{'1': 1024}"
      ]
     },
     "execution_count": 70,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "job = execute(qc, backend, shots=1024)\n",
    "job.result().get_counts(qc)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Here the classical bit by the first measurement is random but the conditional operation results in the qubit being deterministically put into $\\left|1\\right\\rangle$."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Arbitrary initialization\n",
    "What if we want to initialize a qubit register to an arbitrary state? An arbitrary state for $n$ qubits may be specified by a vector of $2^n$ amplitudes, where the sum of amplitude-norms-squared equals 1. For example, the following three-qubit state can be prepared:\n",
    "\n",
    "$$\\left|\\psi\\right\\rangle = \\frac{i}{4}\\left|000\\right\\rangle + \\frac{1}{\\sqrt{8}}\\left|001\\right\\rangle + \\frac{1+i}{4}\\left|010\\right\\rangle + \\frac{1+2i}{\\sqrt{8}}\\left|101\\right\\rangle + \\frac{1}{4}\\left|110\\right\\rangle$$"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 71,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:04.467773Z",
     "start_time": "2018-09-29T00:16:04.437893Z"
    }
   },
   "outputs": [
    {
     "data": {
      "image/png": "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iptER0db7xkZGSn1PHbsmPl5absxKZnU0NDw9ttvBwQEvPvuu+0OotVq+/TpI4QwRXlamTFjho2TVVo1py1przEhREREhPVPpIyioiLpoMNN+ubNmycdtN1xTAhx7969BQsW5Obmbt++3RTtamX69OnSgaWvt+vY8bCkpKQEBgYGBQUlJye3aho3bty5c+eWLFni5eVVWVl59OjRgoKCyspKIURQUNCBAwcSExPlrf+3336T9lIMDw+Xd2QAAAAAAAAAAAAAALohd+mPhISE2bNnnz171svLKzAwsF+/fkKIa9eu3bhxQ9iQdTAZOnSo0Wi03qe2tjYiIqKqqurYsWOPPPKIfXUfPnzYvgs75O/v/9NPP5WUlOzfv7+ysnLIkCFhYWGmHdnadf369YKCgs8++6yLSupufH19AwICrl69KoRIT0+/cuXK999/7+np2W5nT0/PqKio3NzcvLw8g8EgBYbklZeXJ4QYMWKE9R+TYqSllWwhxbDabWppaUlMTNy1a1dWVtYLL7xgaQQpg2UwGJQPCYnOPyzh4eG///67pVZvb+9169alpqYWFBSUlZVVVVX5+flNnjw5NDRUWtusrZMnT9pdfHfLlgEAAAAAAAAAAAAA0KXcTUcPPPCAVqs1b7N9QRTb1dTURERE6PX648ePW1mYx+lCQkJCQkJs7Lxt2zaVShUfH9+lJXUrEyZM2LVrV1VVVWpqanR09KxZs6x0Tk5Ozs3Nra6u/u6772RfD6aqqmr//v1CiFdeeUXekZ2opaUlKSnp22+/3bJly4svvmilpwIZrA516mHpUL9+/eLi4uQazYruli0DAAAAAAAAAAAAAKBLuVlpM61NIldIqKamJjw8vLGx8ciRI905IdRZOp1uxowZfn5+zi5EOdKOY2lpaf/+++/69eutd542bdqYMWOEEF999ZXslWRmZjY3N3t5eS1cuFD2wZ3CaDQuXrw4KysrMzMzISGhw/7S1l1SBqvrq3MRLpktAwAAAAAAAAAAAADACmshIWklIXd3d1mWCblz58706dNVKtWhQ4d8fX0dH7CbKCwsLC0tXbRokbMLUZQUEtq8efOKFStGjBhhvbNKpUpPTxdCFBUVmfZ4kkV9ff3atWuFECkpKa4xqYxG48svv7x169aNGzcmJSXZckmXZrBcletlywAAAAAAAAAAAAAAsM7dUoPRaDx9+rQQIjg4WJY9jBYtWlRcXKzVauPj441G471798xbdTrdoEGDHL+L8nQ6nZ+fX3R0tLMLUdTjjz+uUqn69++/fPlyW/pPnTo1ISFh27Ztn376aW5urlxlrF279ubNm4899tgbb7wh15jO9dprr2VmZo4ZM+bq1avvv/9+Y2Oj0WiUml5//fWhQ4e2vUTKYIWFhUkZrCeeeELZknse18uWAQAAAAAAAAAAAADQIYshoUuXLtXW1gohJk6cKMudKisrhRBHjx5tt/Xu3buy3EVher1+586dycnJ7u4Wv0mXVFhYaDQa169f7+npaeMlaWlpeXl5u3fvzs3NjY2NdbyG0tLSlJQUNze3jRs39urVy/EBna6kpGTDhg1CiIsXL168eNG8SaVSvffee5Yu7KIMlqtyvWwZAAAAAAAAAAAAAAAdsrjdWHFxsXTw5JNPynKn48ePGy3rcMuq7mnXrl16vd7GbaFcRnNz87Jly2bMmBETE2P7VRqNZseOHWq1Ojk5+dq1aw7WUF9fv2DBAoPBkJaWJtcUdbqQkBBLD0hLS8uDDz5o5dq0tDQfHx8pg6VUvT2S62XLAAAAAAAAAAAAAACwhcWQ0Lx58/R6vV6vj4+PV7KgnmXLli2TJk169NFHnV2IolatWlVRUfHll1929sLw8PDMzMwbN27ExMTo9Xq7CzAajYmJicXFxW+99dbSpUvtHseVyJvBclUumS0DAAAAAAAAAAAAAMAWFjfJUqvVarVayVIUM2zYMEcSKub+/vvvVatWyTJU97dy5coxY8ZcunQpJSVl27Ztw4YNs2OQhISEuXPnCiEcmV0qlSorKysrK8vDw8PuQVyPlMFKTEyMiYk5ceKEl5eXsyvqXsiWAQAAAAAAAAAAAADuZxZDQi5s/fr1cg1VXl4u11DdXFNTU2pq6r179/r27ZuRkTF//ny7h5Il2UM8qF2yZLBcFdkyAAAAAAAAAAAAAMD97H4MCcEOarVar9f/888/vr6+LFHTnZGAsYIvBwAAAAAAAAAAAABw3yIkBFv16dMnICDA2VUAAAAAAAAAAAAAAACg09ycXQAAAAAAAAAAAAAAAACArkVICAAAAAAAAAAAAAAAAHBxhIQAAAAAAAAAAAAAAAAAF0dICAAAAAAAAAAAAAAAAHBxhIQAAAAAAAAAAAAAAAAAF0dICAAAAAAAAAAAAAAAAHBx7s4uAOgBGhsbhRCbNm3y9fV1di1wjlOnTjU0NDi7CgAAAAAAAAAAAAAA7ERIyBXo9XohxKuvvtq/f39n19ID1NTUCCHq6+ttv0QKCaWlpXVVTegJvL29nV0CAAAAAAAAAAAAAAB2UhmNRmfXAEfdvHlTq9WOGjXKw8PD2bX0AAaDoby8/OeffyZTBQAAAAAAAAAAAAAA7hP/BTy58OQukbHdAAAAAElFTkSuQmCC\n",
      "text/plain": [
       "<PIL.Image.Image image mode=RGB size=3084x175 at 0x7F0C71790C88>"
      ]
     },
     "execution_count": 71,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "# Initializing a three-qubit quantum state\n",
    "import math\n",
    "desired_vector = [\n",
    "    1 / math.sqrt(16) * complex(0, 1),\n",
    "    1 / math.sqrt(8) * complex(1, 0),\n",
    "    1 / math.sqrt(16) * complex(1, 1),\n",
    "    0,\n",
    "    0,\n",
    "    1 / math.sqrt(8) * complex(1, 2),\n",
    "    1 / math.sqrt(16) * complex(1, 0),\n",
    "    0]\n",
    "\n",
    "\n",
    "q = QuantumRegister(3)\n",
    "\n",
    "qc = QuantumCircuit(q)\n",
    "\n",
    "qc.initialize(desired_vector, [q[0],q[1],q[2]])\n",
    "qc.draw(output='latex')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 72,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:04.575688Z",
     "start_time": "2018-09-29T00:16:04.476846Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "array([0.25      +0.j        , 0.        -0.35355339j,\n",
       "       0.25      -0.25j      , 0.        +0.j        ,\n",
       "       0.        +0.j        , 0.70710678-0.35355339j,\n",
       "       0.        -0.25j      , 0.        +0.j        ])"
      ]
     },
     "execution_count": 72,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "backend = BasicAer.get_backend('statevector_simulator')\n",
    "job = execute(qc, backend)\n",
    "qc_state = job.result().get_statevector(qc)\n",
    "qc_state "
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "[Fidelity](https://en.wikipedia.org/wiki/Fidelity_of_quantum_states) is useful to check whether two states are same or not.\n",
    "For quantum (pure) states $\\left|\\psi_1\\right\\rangle$ and $\\left|\\psi_2\\right\\rangle$, the fidelity is\n",
    "\n",
    "$$\n",
    "F\\left(\\left|\\psi_1\\right\\rangle,\\left|\\psi_2\\right\\rangle\\right) = \\left|\\left\\langle\\psi_1\\middle|\\psi_2\\right\\rangle\\right|^2.\n",
    "$$\n",
    "\n",
    "The fidelity is equal to $1$ if and only if two states are same."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 73,
   "metadata": {
    "ExecuteTime": {
     "end_time": "2018-09-29T00:16:04.607616Z",
     "start_time": "2018-09-29T00:16:04.580046Z"
    }
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "1.0"
      ]
     },
     "execution_count": 73,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "state_fidelity(desired_vector,qc_state)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "#### Further details:\n",
    "\n",
    "How does the desired state get generated behind the scenes? There are multiple methods for doing this. Qiskit uses a [method proposed by Shende et al](https://arxiv.org/abs/quant-ph/0406176). Here, the idea is to assume the quantum register to have started from our desired state, and construct a circuit that takes it to the $\\left|00..0\\right\\rangle$ state. The initialization circuit is then the reverse of such circuit.\n",
    "\n",
    "To take an arbitrary quantum state to the zero state in the computational basis, we perform an iterative procedure that disentangles qubits from the register one-by-one. We know that any arbitrary single-qubit state $\\left|\\rho\\right\\rangle$ can be taken to the $\\left|0\\right\\rangle$ state using a $\\phi$-degree rotation about the Z axis followed by a $\\theta$-degree rotation about the Y axis:\n",
    "\n",
    "$$R_y(-\\theta)R_z(-\\phi)\\left|\\rho\\right\\rangle = re^{it}\\left|0\\right\\rangle$$\n",
    "\n",
    "Since now we are dealing with $n$ qubits instead of just 1, we must factorize the state vector to separate the Least Significant Bit (LSB):\n",
    "\n",
    "$$\\begin{align*}\n",
    " \\left|\\psi\\right\\rangle =& \\alpha_{0_0}\\left|00..00\\right\\rangle + \\alpha_{0_1}\\left|00..01\\right\\rangle + \\alpha_{1_0}\\left|00..10\\right\\rangle + \\alpha_{1_1}\\left|00..11\\right\\rangle + ... \\\\&+ \\alpha_{(2^{n-1}-1)_0}\\left|11..10\\right\\rangle + \\alpha_{(2^{n-1}-1)_1}\\left|11..11\\right\\rangle \\\\\n",
    "=& \\left|00..0\\right\\rangle (\\alpha_{0_0}\\left|0\\right\\rangle + \\alpha_{0_1}\\left|1\\right\\rangle) + \\left|00..1\\right\\rangle (\\alpha_{1_0}\\left|0\\right\\rangle + \\alpha_{1_1}\\left|1\\right\\rangle) + ... \\\\&+ \\left|11..1\\right\\rangle (\\alpha_{(2^{n-1}-1)_0}(\\left|0\\right\\rangle + \\alpha_{(2^{n-1}-1)_1}\\left|1\\right\\rangle) \\\\\n",
    "=& \\left|00..0\\right\\rangle\\left|\\rho_0\\right\\rangle + \\left|00..1\\right\\rangle\\left|\\rho_1\\right\\rangle + ... + \\left|11..1\\right\\rangle\\left|\\rho_{2^{n-1}-1}\\right\\rangle\n",
    "\\end{align*}$$\n",
    "\n",
    "Now each of the single-qubit states $\\left|\\rho_0\\right\\rangle, ..., \\left|\\rho_{2^{n-1}-1}\\right\\rangle$ can be taken to $\\left|0\\right\\rangle$ by finding appropriate $\\phi$ and $\\theta$ angles per the equation above. Doing this simultaneously on all states amounts to the following unitary, which disentangles the LSB:\n",
    "\n",
    "$$U = \\begin{pmatrix} \n",
    "R_{y}(-\\theta_0)R_{z}(-\\phi_0) & & & &\\\\  \n",
    "& R_{y}(-\\theta_1)R_{z}(-\\phi_1) & & &\\\\\n",
    "& . & & &\\\\\n",
    "& & . & &\\\\\n",
    "& & & & R_y(-\\theta_{2^{n-1}-1})R_z(-\\phi_{2^{n-1}-1})\n",
    "\\end{pmatrix} $$\n",
    "\n",
    "Hence,\n",
    "\n",
    "$$U\\left|\\psi\\right\\rangle = \\begin{pmatrix} r_0e^{it_0}\\\\ r_1e^{it_1}\\\\ . \\\\ . \\\\ r_{2^{n-1}-1}e^{it_{2^{n-1}-1}} \\end{pmatrix}\\otimes\\left|0\\right\\rangle$$\n",
    "\n",
    "\n",
    "U can be implemented as a \"quantum multiplexor\" gate, since it is a block diagonal matrix. In the quantum multiplexor formalism, a block diagonal matrix of size $2^n \\times 2^n$, and consisting of $2^s$ blocks, is equivalent to a multiplexor with $s$ select qubits and $n-s$ data qubits. Depending on the state of the select qubits, the corresponding blocks are applied to the data qubits. A multiplexor of this kind can be implemented after recursive decomposition to primitive gates of cx, rz and ry."
   ]
  }
 ],
 "metadata": {
  "anaconda-cloud": {},
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.7.3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 1
}
