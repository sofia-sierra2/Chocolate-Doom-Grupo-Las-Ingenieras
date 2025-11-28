import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import json

def calculate_mean(input_list):
    return sum(input_list)/len(input_list)



no_index_set                    = calculate_mean([15.992,17.113,17.387,21.750])
index_time                      = calculate_mean([15.469,16.450,17.180,19.039])


data_type_index =  {
    'Index': ['No Index', 'B-Tree'],
    'Execution Time': [
        no_index_set,
        index_time
    ]
}

df = pd.DataFrame(data_type_index)

fig, ax     = plt.subplots()
execution_time_index_comp = plt.bar(df['Index'], df['Execution Time'], color='skyblue')

ax.bar_label(execution_time_index_comp, label_type='edge', color='black', fontsize=10) 

plt.xlabel('Index')
plt.ylabel('Execution Time (ms)')
plt.title('Execution Time By Index Type')

plt.show()




# Hash_execution_times            = [0.203,0.178,0.195,0.169,0.351]
# B_tree_execution_times          = [0.513,0.266,0.252,0.242,0.172]
# Brin_execution_times            = [28.923,33.706,24.871,31.987,32.666]

# mean_Hash_execution_times       = round(calculate_mean(Hash_execution_times),4)
# mean_B_tree_execution_times     = round(calculate_mean(B_tree_execution_times),4)
# mean_Brin_execution_times       = round(calculate_mean(Brin_execution_times),4)


# data_type_index = {
#     'Index': ['Hash', 'B-Tree', 'Brin'],
#     'Execution Time': [
#         mean_Hash_execution_times,
#         mean_B_tree_execution_times,
#         mean_Brin_execution_times
#     ]
# }

# print(json.dumps(data_type_index,indent=4))

# df = pd.DataFrame(data_type_index)

# fig, ax     = plt.subplots()
# execution_time_index_comp = plt.bar(df['Index'], df['Execution Time'], color='skyblue')


# ax.bar_label(execution_time_index_comp, label_type='edge', color='black', fontsize=10) 

# plt.xlabel('Index')
# plt.ylabel('Execution Time (ms)')
# plt.title('Execution Time By Index Type')

# plt.show()

# Q2_execution_times                      = [13.840,20.437,13.417,21.404,13.320]
# Q3_execution_times                      = [23.262,20.404,22.444,24.328,29.699]
# Q4_execution_times                      = [1.085,1.162,1.587,1.038,2.308]
# Q5_execution_times                      = [0.142,0.533,0.928,0.152,0.378]

# Q2_execution_times_indexed              = [3.038,0.730,2.682,0.942,2.744]
# Q3_execution_times_indexed              = [0.348,0.180,0.205,0.220,0.313]
# Q4_execution_times_indexed              = [0.076,1.092,0.219,0.073,2.057]
# Q5_execution_times_indexed              = [0.098,0.081,0.132,0.065,0.120]

# mean_Q2_execution_times                 = round(calculate_mean(Q2_execution_times),4)
# mean_Q3_execution_times                 = round(calculate_mean(Q3_execution_times),4)
# mean_Q4_execution_times                 = round(calculate_mean(Q4_execution_times),4)
# mean_Q5_execution_times                 = round(calculate_mean(Q5_execution_times),4)

# mean_Q2_execution_times_indexed         = round(calculate_mean(Q2_execution_times_indexed),4)
# mean_Q3_execution_times_indexed         = round(calculate_mean(Q3_execution_times_indexed),4)
# mean_Q4_execution_times_indexed         = round(calculate_mean(Q4_execution_times_indexed),4)
# mean_Q5_execution_times_indexed         = round(calculate_mean(Q5_execution_times_indexed),4)

# data_comparisson = {
#     'Query': ['Q2', 'Q3', 'Q4', 'Q5'],
#     'Mean Time': [
#         mean_Q2_execution_times,
#         mean_Q3_execution_times,
#         mean_Q4_execution_times,
#         mean_Q5_execution_times
#     ],
#     'Mean Time Indexed': [
#         mean_Q2_execution_times_indexed,
#         mean_Q3_execution_times_indexed,
#         mean_Q4_execution_times_indexed,
#         mean_Q5_execution_times_indexed
#     ]
# }


# df          = pd.DataFrame(data_comparisson)
# w, x        = 0.2, np.arange(len(data_comparisson['Query']))
# fig, ax     = plt.subplots()

# mean_time_bars = ax.bar(x - w/2, df['Mean Time'], width=w, label='Mean Time')
# mean_time_bars_indexed = ax.bar(x + w/2, df['Mean Time Indexed'], width=w, label='Mean Time Indexed')

# ax.bar_label(mean_time_bars, label_type='edge', color='black', fontsize=10)
# ax.bar_label(mean_time_bars_indexed, label_type='edge', color='black', fontsize=10) 

# plt.xlabel('Query')
# ax.set_xticks(x)
# ax.set_xticklabels(data_comparisson['Query'])
# plt.ylabel('Execution Time (ms)')
# plt.title('Execution Time Comparisson with Index')
# ax.legend()

# plt.show()

# print(json.dumps(data_comparisson, indent=4))
