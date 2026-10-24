inc b ;начинаем с 1
loop:
  add a, b ;следующие число - сумма двух предыдущих
  adc c, d
  jc end ;если есть переполнение, останвливаемся
  st a, 0xff ;выводим число
  st c, 0xfe
  ;тоже самое, но для других регистров
  add b, a
  adc d, c
  jc end
  st b, 0xff
  st d, 0xfe
  jmp loop ;повторяем
end:
  hlt ;конец
