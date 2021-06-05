#pragma once

void miniuart_init();
char miniuart_recv();
void miniuart_send(char c);
void miniuart_send_string(const char *str);
