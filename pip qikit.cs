sudo apt install python-pip
pip install qiskit
jupyter console

import qiskit as qk
qr = qk.QuantumRegister(2)
cr = qk.ClassicalRegister(2)
qc = qk.QuantumCircuit(qr,cr)

qc.h(qr[0])
qc.cx(qr[0],qr[1])

measure_Z = qk.QuantumCircuit(qr,cr)
measure_Z.measure(qr,cr)

measure_X = qk.QuantumCircuit(qr,cr)
measure_X.h(qr)
measure_X.measure(qr,cr)

test_Z = qc + measure_Z
test_X = qc + measure_X

from qiskit import execute, IBMQ
IBMQ.enable_account("Paste your APItoken here")

backend = IBMQ.get_backend('ibmqx4')

job= qk.execute([test_Z, test_X], backend = backend, shots = 1000)

result = job.result()
result.get_counts(test_Z)
result.get_counts(test_X)
from qiskit.tools.visualization import plot_histogram
plot_histogram(result.get_counts(test_Z))

from qiskit import Aer
backend = Aer.get_backend('qasm_simulator')
job = qk.execute([test_Z, test_X], backend= backend, shots=1000)
result = job.result()
plot_histogram(result.get_counts(test_Z))

