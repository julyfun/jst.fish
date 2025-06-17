#!/usr/bin/env python3
import os
import sys
import json  # 使用json而不是toml

try:
    data_home = os.environ['JST_DATA_HOME']
except KeyError:
    print("$JST_DATA_HOME does not exist. Exiting.")
    sys.exit(1)

cmd = sys.argv[1:]
path = "/".join([data_home, "usage_count.json"])  # 修改文件扩展名为.json

# check if not exist, then create an empty json

# 检查文件是否存在
if not os.path.exists(path):
    initial_data = {}  # 例如，一个空字典
    with open(path, 'w') as file:
        json.dump(initial_data, file, indent=4)
    print(f"'{path}' has been created with initial data.")

def read_modify_write_json(file_path, key_path):
    try:
        with open(file_path, 'r') as f:
            data = json.load(f) # a dict
        # 寻找指定的键
        temp = data
        for key in key_path[:-1]:
            # temp = temp.setdefault(key, {})
            nxt = temp.get(key)
            if nxt is None or not isinstance(nxt, dict):
                temp[key] = {}
            temp = temp.get(key)
        # 获取当前值，如果不存在或类型不正确则使用默认值
        current_value = temp.get(key_path[-1], 0)
        if not isinstance(current_value, int):
            current_value = 0
        temp[key_path[-1]] = current_value + 1

        # 写回JSON文件
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=4)  # 可以添加indent参数美化输出

    except Exception as e:
        print(f"Error: {e}")

read_modify_write_json(path, cmd)
