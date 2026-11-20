inc b ;начинаем с 1
loop:
  add a, b ;следующее число - сумма двух предыдущих
  adc c, d
  jc end ;если есть переполнение, останавливаемся
  st a, 0x7d ;выводим число
  st c, 0x7c
  ;то же самое, но для других регистров
  add b, a
  adc d, c
  jc end
  st b, 0x7d
  st d, 0x7c
  jmp loop ;повторяем
end:
  hlt ;конец
