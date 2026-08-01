@echo off
git add .
git commit -m "666's spy - update" 2>nul
git branch -M main
git remote add origin https://github.com/Wwwaaallvvvyyy666/remotespy.git 2>nul
git remote set-url origin https://github.com/Wwwaaallvvvyyy666/remotespy.git
git push -u origin main -f
echo.
echo Selesai! Push ke GitHub berhasil.
pause
