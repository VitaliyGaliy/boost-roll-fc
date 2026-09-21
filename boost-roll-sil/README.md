# Boost roll SIL

Окремий простий проєкт: **1-ша сходинка вздовж фюзеляжу**, старт **45°**, мотори дрона не працюють, крен тримають **канарди/елерони**, закон як у **ArduPlane `RLL2SRV_*`**.

Це не форк `CC_Flight_Simulation`. Числа в `params_vehicle.m` — оцінки, їх треба замінити своїми.

## Запуск

У MATLAB:

```matlab
cd('.../boost-roll-sil')
run_boost_roll          % 8 с: буст + короткий coast
run_boost_roll(12)
```

У Simulink: відкрийте `BoostRollSIL.slx` (або `open_system('BoostRollSIL')` із цієї теки) і натисніть **Run**. Scope `Scope_phi` відкривається сам. Перед цим MATLAB Current Folder має бути `boost-roll-sil`, або виконайте `boost_roll_slx_setup`.

У Command Window друкуються пропоновані `RLL2SRV_*`. Графіки: \(\phi\), \(p\), \(\delta\), швидкість, висота.

## Що змінювати

| Файл | Зміст |
|---|---|
| `params_vehicle.m` | маса, тяга, \(I_{xx}\), керма, ексцентриситет |
| `params_ardupilot.m` | PID / TCONST / RMAX |
| `params_vehicle.m` → `free_pitch` | `true` вмикає \(C_{N\alpha}\) і знос тангажу з 45° |

## Модель

- Тяга вздовж осі корпусу, маса падає лінійно за `burn_time_s`.
- Крен: \(I_{xx}\dot p = q S_{\mathrm{ctrl}} d\, C_{L\delta}\delta + T\,\ell_{\mathrm{ecc}} - b p\).
- Поки \(s <\) `rail_length_m`, крен затиснутий (напрямна). На нульовій швидкості керма не працюють.
- Серво — аперіодика `servo_tau_s`.
- Контролер 50 Гц: помилка кута → бажана \(p\) → P+I+D+FF, вихід \([-1,1]\).

На залізі: прошивка **ArduPlane** (MatekH743), канал керма = aileron, не `ATC_RAT_RLL_*` квада. Режим **FBWA**. `plane_roll_boost.parm` **цілком не заливати** (там чужі PID і застарілий `ARMING_SKIPCHK=260`).

Bring-up без піто/GPS: `ardupilot/matek_h743_fbwa_bringup.parm` → IMU/орієнтація → знак `SERVOx_REVERSED` у FBWA → земля → лог. Ланцюжок і HUD-перевірки — у `rocket_roll_plant/README.md`.
