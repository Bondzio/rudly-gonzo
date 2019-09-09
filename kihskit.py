# To add a new cell, type '#%%'
# To add a new markdown cell, type '#%% [markdown]'
from qiskit.tools.visualization import plot_histogram, plot_circuit
input open object import
plot_histogram(result.get_counts())

from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit import execute, register
from qiskit import IBMQ, Aer

# register if you have a token
API_TOKEN = ''
if(API_TOKEN != ''):
    IBMQ.enable_account(API_TOKEN, "https://quantumexperience.ng.bluemix.net/api")

# declaration
QR =QuantumRegister(2, 'q')
CR = ClassicalRegister(2, 'c')
QC = QuantumCircuit(QR, CR, name='Bell state')
# Build your Circuit
QC.h(QR[0])
QC.cx(QR[0], QR[1])
QC.measure(QR[0], CR[0])
QC.measure(QR[1], CR[1])
# chceck for avaialbale backends
PREFERRED_BACKEND = ''
if PREFERRED_BACKEND != '':
    backend_object = Aer.get_backend(PREFERRED_BACKEND)
 else:
    backend_object = Aer.get_backend('qasm_simulator')
# execute it
if __name__ == '__main__':
    execution_job = execute(QC, backend_object)
    result = execution_job.result()
    print(result.get_counts())
