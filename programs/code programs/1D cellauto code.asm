mode:
  ld a, in ;читаем режим
  dec a ;если введён первый, генерируем случайные клетки
  jz random
  dec a ;если второй, спрашиваем стартовые клетки у пользователя
  jnz mode
set:
  ld a, in ;читаем клетки для левой половины
  st a, display_left ;сохраняем и выводим
  ld a, in ;читаем клетки для правой половины
  st a, display_right ;сохраняем и выводим
  jmp read_rule ;переходим к чтению правила
random:
  rnd a ;генерируем клетки для левой половины
  rnd b ;генерируем клетки для правой половины
  st a, display_left ;сохраняем и выводим
  st b, display_right ;сохраняем и выводим
read_rule:
  ld a, in ;читаем правило
  st a, rule ;сохраняем
clear_start:
  clr a ;очищаем
  ldi b, clear_loop ;адрес цикла
  ldi c, 16 ;счётчик
  ldi d, cells ;адрес клеток
clear_loop: ;очищаем состояния клеток
  st a, d ;очищаем состояние одной клетки
  inc d ;следующая клетка
  dec c ;если клетки ещё остались, продолжаем очищать
  jnz b
ldi d, cells ;адрес клеток
left: ;настройки для левой половины
  ldi c, 0b00000010 ;угловые начинаются со 2 позиции
  st c, set_edge + 1
  ldi c, center ;после угловых переходим к центральным
  st c, edge_jmp + 1
  ldi c, right ;после центральных переходим к правой половине
  st c, center_jmp + 1
  ld c, display_left ;читаем левую половину
edge:
  shl c ;сдвигаем
  jnc edge_jmp ;если клетки нет, значит угол пуст
set_edge:
  ldi a, 0b00000010 ;иначе добавляем соседей
  ld b, d ;читаем состояние
  or b, a ;добавляем соседа
  st b, d ;сохраняем
  shl a ;сдвигаем
  inc d ;следующая клетка
  ;то же самое, но для следующей клетки
  ld b, d
  or b, a
  st b, d
  dec d ;восстанавливаем указатель в начало
edge_jmp:
  jmp center ;заменяемый переход
center:
  ldi a, 8 ;восстанавливаем счётчик
  st a, i
center_loop:
  ld a, i ;читаем счётчик
center_dec:
  dec a ;уменьшаем
center_jmp: jz right ;если клетки ещё остались, продолжаем
  st a, i ;сохраняем
  shl c ;сдвигаем
  jc set_center ;если клетка есть, добавляем соседей
  inc d ;следующая клетка
  jmp center_dec ;переходим на уменьшение счётчика
set_center:
  ldi a, 0b00000001
  ld b, d ;читаем состояние
  or b, a ;добавляем соседа
  st b, d ;сохраняем
  shl a ;сдвигаем
  inc d ;следующая клетка
  ;то же самое, но для следующих двух клеток
  ld b, d
  or b, a
  st b, d
  shl a
  inc d
  ld b, d
  or b, a
  st b, d
  dec d
  jmp center_loop ;повторяем
right: ;настройки для правой половины
  ldi c, 0b00000001 ;угловые начинаются с 1 позиции
  st c, set_edge + 1
  ldi c, draw ;после угловых переходим к отрисовке
  st c, edge_jmp + 1
  ldi c, edge ;после центральных переходим к угловым
  st c, center_jmp + 1
  ld c, display_right ;читаем правую половину
  jmp center
void db 0, 0
display_left db 0 ;левая половина дисплея
display_right db 0 ;правая половина дисплея
in db 0 ;ввод
bank db 0 ;банк (не используется)
draw: ;отрисовка
  ldi c, cells ;адрес клеток
draw_loop_start:
  clr b ;очищаем байт клеток
  st b, byte
  ldi b, 0b10000000 ;маска
draw_loop:
  ld a, c ;читаем состояние клетки
  ldi d, 0b00000001 ;сдвигаем на нужную позицию в правиле
  shl_loop:
    shl d
    dec a
    jns shl_loop
  rcr d
  ld a, rule ;читаем правило
  and a, d ;если состояние соответствует правилу, клетка рождается/выживает
  jz draw_loop_end ;иначе умирает/остаётся мёртвой
  ld a, byte ;читаем байт клеток
  or a, b ;добавляем живую клетку
  st a, byte ;сохраняем
draw_loop_end:
  inc c ;следующая клетка
  shr b ;сдвигаем маску
  jnc draw_loop ;если маска осталась, продолжаем
  ld a, stop ;читаем флаг
  not a ;инвертируем
  st a, stop ;сохраняем
  jz end ;если после инвертации флаг погас, значит переходим в конец
  ;иначе повторяем для правых клеток
  ld a, byte ;читаем байт
  st a, save ;сохраняем
  jmp draw_loop_start ;переходим к старту цикла
end: ;конец
  ld a, save ;читаем левую половину
  st a, display_left ;сохраняем и выводим
  ld a, byte ;читаем правую половину
  st a, display_right ;сохраняем и выводим
  jmp clear_start ;повторяем
byte db 0 ;байт
stop db 0 ;флаг
i db 0 ;счётчик
rule db 0 ;правило
save db 0 ;сохранение
cells db 0, 0, 0, 0, 0, 0, 0, 0, ;клетки
0, 0, 0, 0, 0, 0, 0, 0
