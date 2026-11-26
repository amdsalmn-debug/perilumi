pkg=com.salman.perilumi
adb install -r build/perilumi.apk
read W H <<<"$(adb shell wm size | tail -1 | grep -oE '[0-9]+x[0-9]+' | tr x ' ')"
tap() { adb shell input tap $((W * $1 / 100)) $((H * $2 / 100)); }
adb logcat -c
for x in 18 50 82; do
  adb shell am force-stop $pkg
  adb shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  sleep 25
  tap $x 84; sleep 5
  for i in $(seq 1 25); do
    for p in "28 34" "72 34" "50 38" "28 52" "72 52" "50 52" "22 52" "78 52"; do tap $p; sleep 0.4; done
    if ! adb shell pidof $pkg >/dev/null; then echo "KAPANDI grup=$x tur=$i"; break; fi
  done
  echo "SONUC grup=$x pid=$(adb shell pidof $pkg)"
done
echo ==== LOG
adb logcat -d -v brief | grep -E "FATAL|AndroidRuntime|Fatal signal|DEBUG +\(|godot|Godot|lowmemory|ANR in|Process .*died" | tail -150
