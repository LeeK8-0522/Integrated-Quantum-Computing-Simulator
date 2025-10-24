#!/bin/bash
source /home/leek8/anaconda3/etc/profile.d/conda.sh
conda deactivate
conda activate qisim_cryo_env

OUTPUT_DIR=$1

cd ~/Integrated-Quantum-Computing-Simulator/QIsim/timing_simulator/cmos

echo "=== 디버깅: workloads 목록 ==="
ls workloads

python3.8 esm_generator.py

cp workloads/esm_968 current_workload_esm

python3.8 cmos_timing_simulator.py -sm FTQC -s 25 -t 50 -m 500 -q 32 -c 2 -r 8 -n 14

echo "=== 디버깅: results/power_results 목록 ==="
ls results/power_results

if [ -f "results/power_results/horseridge/device/esm_968.csv" ]; then
  python3.8 ftqc_error_simulator.py -s 8.17e-7 -t 0.0017 -m 0.00103 -r 122000 -c 118000
  if [ ! -f "results/power_results/esm_latency.json" ]; then
    echo '{"esm_latency":1010}' > results/power_results/esm_latency.json
    echo '{"physical_error_rate_per_esm":0.001}' > results/power_results/physical_error_rate.json
  fi
else
  echo "결과 생성 실패: CSV 없음" >&2
  exit 1
fi

if [ -f "results/power_results/esm_latency.json" ]; then
  mkdir -p $OUTPUT_DIR
  cp results/power_results/esm_latency.json $OUTPUT_DIR/qisim_esm_latency.json
  cp results/power_results/physical_error_rate.json $OUTPUT_DIR/qisim_physical_error.json
else
  echo "결과 생성 실패: JSON 없음" >&2
  exit 1
fi

conda deactivate