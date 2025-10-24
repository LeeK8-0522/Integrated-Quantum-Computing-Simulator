#!/bin/bash
source /home/leek8/anaconda3/etc/profile.d/conda.sh
conda deactivate
conda activate xqsim_env

QISIM_JSON=$1
OUTPUT_DIR=$2
WORKLOAD=$3
DEBUG=$4  # 추가 인자: 디버그 모드

echo "=== 디버깅: QIsim JSON 내용 ==="
cat $QISIM_JSON

PHYS_ERR=$(jq '.physical_error_rate_per_esm' $QISIM_JSON)

cd ~/Integrated-Quantum-Computing-Simulator/XQsim/src/XQ-simulator

sed -i "s/\"num_lq\": [0-9]*/\"num_lq\": 5/" ../configs/example_cmos_d5.json
sed -i "s/\"physical_error_rate\": .*/\"physical_error_rate\": $PHYS_ERR/" ../configs/example_cmos_d5.json

export PYTHONWARNINGS="ignore:pkg_resources is deprecated"

# 디버그 모드 전달
python ../xqsim.py -c example_cmos_d5 -b $WORKLOAD -s 10 -ds False -rs False -de False -re False -di True -ri True -sp False -db $DEBUG

echo "=== 디버깅: simres 목록 ==="
ls simres/example_cmos_d5

if [ -f "simres/example_cmos_d5/${WORKLOAD}.stat" ]; then
  mkdir -p $OUTPUT_DIR
  cp simres/example_cmos_d5/${WORKLOAD}.stat $OUTPUT_DIR/xqsim_patch_latency.json
  cp simres/example_cmos_d5/${WORKLOAD}.pqsim $OUTPUT_DIR/xqsim_logical_error.json
else
  echo "XQsim 결과 생성 실패" >&2
  exit 1
fi

conda deactivate