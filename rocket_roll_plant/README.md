# rocket_roll_plant (мінімальна модель під перенесення на ArduPlane)

```matlab
cd('.../rocket_roll_plant')
init_roll_model
apply_fc_minimal
open_system('rocket_roll_plant')
```

Усі числа для налаштування — у `init_roll_model.m`. `plane_roll_boost.parm` на Matek цілком не заливати.

```
phi_cmd → Angle P → p_cmd → Rate PID+FF → δ_cmd → Servo → Plant → p, φ
p_true → Gyro → p_meas → sample(Ts) → delay → rate loop
```

Модель заморожена (каскад, Ts=0.01, Gyro→ZOH→Unit Delay, серво/plant неперервні). Аеро — placeholders.

## Залізо (наступний крок, не модель)

Мета: **Matek H743-Wing + ArduPlane**, режим **FBWA**, без піто і GPS. Заливати лише `../boost-roll-sil/ardupilot/matek_h743_fbwa_bringup.parm`, не SIL-PID.

1. **Firmware** — firmware.ardupilot.org → Plane → **MatekH743**. Перший раз: DFU + `with_bl.hex`, далі `.apj`. Не Copter, не `ATC_RAT_RLL_*`.
2. **IMU / орієнтація** — плата стрілкою за польотом (або `AHRS_ORIENTATION` під факт). Accel calib. HUD: ніс угору → горизонт униз, крен праворуч → горизонт ліворуч. Інакше FBWA крутитиме не туди.
3. **Серво / знак** — канал канарди `SERVOx_FUNCTION=4`. Знак правити **`SERVOx_REVERSED`**, не реверсом на пульті. Стик не чіпати: крен корпусу праворуч → кермо має зменшувати цей крен.
4. **Земля** — FBWA, sticks center, похитати ракету; потім стик крену. MANUAL окремо. Мотори не потрібні. `ARMING_SKIPCHK` лишити 0.
5. **Лог** — microSD, `LOG_DISARMED=1`. Після хитання: `ATT`, `IMU`, `CTUN`, `RCOU` / `RCIN`. Звіряти знак `p` з HUD, не з числами SIL.

`RLL2SRV_*` з плати не копіювати з `init_roll_model` і не з `params_ardupilot.m`: одиниці інші (рад → δ vs нормоване серво). TCONST/RMAX/PID — після землі.
