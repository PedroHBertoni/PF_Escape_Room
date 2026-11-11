import gleam/io

pub type MainMenu {
  Explorar
  Inventario
  Enigmas
  Sair
}

pub fn display_main_menu() {
  io.println("--- MENU PRINCIPAL ---")
  io.println("m1(): Explorar ambiente")
  io.println("m2(): Consultar inventário")
  io.println("m3(): Examinar enigmas")
  io.println("exit(): Encerrar simulação")
}

pub fn m1() -> MainMenu {
  Explorar
}

pub fn m2() -> MainMenu {
  Inventario
}

pub fn m3() -> MainMenu {
  Enigmas
}

pub fn exit() -> MainMenu {
  Sair
}
