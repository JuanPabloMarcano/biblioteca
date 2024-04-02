program Biblioteca;

uses
  crt, sysutils, DateUtils;

type
  tEstudiantes = record
    nombre: string[30];
    apellido: string[30];
    Edad: LongInt;
    Cedula: LongInt;
    Carrera: String[30];
    Sancionado: boolean;
  end;

type
  tPrestamo = record
    Cedula: integer;
    Titulo: string[30];
    autor: string[30];
    FechaSalida: string[30];
    NumeroPaginas: string[30];
    FechaDevolucion: string[30];
  end;

type
  tLibro = record
    Titulo: string[30];
    autor: string[30];
    FechaSalida: string[30];
    NumeroPaginas: string[30];
    Existencias: integer;
  end;

var
  opcion: integer;
  Estudiante: tEstudiantes;
  Prestamo: tPrestamo;
  Libro: tLibro;
  txt,tempFile: Text;
  sancionadoStr: string;

procedure RegistrarNuevoAlumno;
var
  inputStr: AnsiString;
begin
  assign(txt, 'Personas.txt');
  append(txt);
  writeln('Ingrese su nombre: ');
  readln(Estudiante.nombre);
  writeln('Ingrese su apellido: ');
  readln(Estudiante.apellido);
  writeln('Ingrese su edad: ');
  readln(inputStr);
  while not TryStrToInt(inputStr, Estudiante.Edad) do
  begin
    writeln('La edad que ha intentado ingresar es invalida. Ingrese un numero valido: ');
    readln(inputStr);
  end;
  writeln('Ingrese su Cedula: ');
  readln(inputStr);
  while not TryStrToInt(inputStr, Estudiante.Cedula) do
  begin
    writeln('Cedula invalida. Por favor, ingrese un numero valido: ');
    readln(inputStr);
  end;
  writeln('Ingrese la carrera universitaria: ');
  readln(Estudiante.Carrera);
  Estudiante.Sancionado := False;
  writeln(txt, Estudiante.nombre);
  writeln(txt, Estudiante.apellido);
  writeln(txt, Estudiante.Edad);
  writeln(txt, Estudiante.Cedula);
  writeln(txt, Estudiante.Carrera);
  writeln(txt, Estudiante.Sancionado);
  close(txt);
  writeln('Ha sido registrado con exito.');
end;


// PROCEDURE REGISTRAR PRESTAMO
procedure RegistrarPrestamo;
var
  encontrado, libroDisponible, tienePrestamoActivo: Boolean;
  cedulaPrestamo, diasPrestamo: integer;
  fechaSalidaLibro, fechaActual: TDateTime;
  txt, tempFile: Text;
begin
  encontrado := False;
  libroDisponible := False;
  tienePrestamoActivo := False;
  
  // Para buscar al estudiante
  assign(txt, 'Personas.txt');
  reset(txt);
  if IOResult <> 0 then
  begin
    writeln('Ha habido un error al abrir el archivo.');
    Exit;
  end;
  
  writeln('Ingrese la cedula para el prestamo: ');  
  readln(cedulaPrestamo);  
  while not eof(txt) do
  begin
    readln(txt, Estudiante.nombre);
    readln(txt, Estudiante.apellido);
    readln(txt, Estudiante.Edad);
    readln(txt, Estudiante.Cedula);
    readln(txt, Estudiante.Carrera);
    readln(txt, sancionadoStr);
    Estudiante.Sancionado := sancionadoStr = 'True';
  
    if Estudiante.Cedula = cedulaPrestamo then
    begin
      encontrado := True;
      break;
    end;
  end;
  close(txt);
  
  if not encontrado then
  begin
    writeln('El alumno no se ha registrado previamente.');
    Exit;
  end;

  // Validacion de prestamos activos, del estudiante
  assign(txt, 'Prestamo.txt');
  reset(txt);
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    if Prestamo.Cedula = cedulaPrestamo then
    begin
      tienePrestamoActivo := True;
      if TryStrToDate(Prestamo.FechaSalida, fechaSalidaLibro) then
        break
      else
      begin
        writeln('Fecha de salida del libro no es valida: ', Prestamo.FechaSalida);
        Exit;
      end;
    end;
  end;
  close(txt);
  
  if tienePrestamoActivo then
  begin
    writeln('El alumno ya cuenta con un prestamo activo.');
    writeln('Hace cuantos dias tiene el libro?');
    readln(diasPrestamo);
    
    if diasPrestamo > 3 then
    begin
      writeln('El alumno se ha excedido el limite de 3 días. No podra solicitar otro prestamo.');
      
      // Actualizar archivo para los estudiantes que cuentan con una sancion
      assign(txt, 'Personas.txt');
      reset(txt);
      
      assign(tempFile, 'TempPersonas.txt');
      rewrite(tempFile);
      
      while not eof(txt) do
      begin
        readln(txt, Estudiante.nombre);
        readln(txt, Estudiante.apellido);
        readln(txt, Estudiante.Edad);
        readln(txt, Estudiante.Cedula);
        readln(txt, Estudiante.Carrera);
        readln(txt, sancionadoStr);
        Estudiante.Sancionado := sancionadoStr = 'True';
        
        if Estudiante.Cedula = cedulaPrestamo then
          Estudiante.Sancionado := True;
        
        writeln(tempFile, Estudiante.nombre);
        writeln(tempFile, Estudiante.apellido);
        writeln(tempFile, Estudiante.Edad);
        writeln(tempFile, Estudiante.Cedula);
        writeln(tempFile, Estudiante.Carrera);
        writeln(tempFile, Estudiante.Sancionado);
      end;
      
      close(txt);
      close(tempFile);
      
      erase(txt); 
      rename(tempFile, 'Personas.txt');  // Renombra el archivo temporal al nombre original
      
      Exit; 
    end;
  end;

  // Buscar el libro
  assign(txt, 'NuevoLibro.txt');
  reset(txt);
  writeln('Ingrese el Titulo del Libro: ');  
  readln(Prestamo.Titulo);
  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);
    readln(txt, Libro.FechaSalida);
    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);
    
    if Libro.Titulo = Prestamo.Titulo then
    begin
      libroDisponible := Libro.Existencias > 0;
      if TryStrToDate(Libro.FechaSalida, fechaSalidaLibro) then
        break
      else
      begin
        writeln('La fecha de salida del libro no es valida: ', Libro.FechaSalida);
        Exit;
      end;
    end;
  end;
  close(txt);
  
 
  
  // Actualizar las existencias del libro
  assign(txt, 'NuevoLibro.txt');
reset(txt);

assign(tempFile, 'NuevoLibroTemp.txt');
rewrite(tempFile);

while not eof(txt) do
begin
  readln(txt, Libro.Titulo);
  readln(txt, Libro.autor);
  readln(txt, Libro.FechaSalida);
  readln(txt, Libro.NumeroPaginas);
  readln(txt, Libro.Existencias);
  
  if Libro.Titulo = Prestamo.Titulo then
    Dec(Libro.Existencias);
  
  writeln(tempFile, Libro.Titulo);
  writeln(tempFile, Libro.autor);
  writeln(tempFile, Libro.FechaSalida);
  writeln(tempFile, Libro.NumeroPaginas);
  writeln(tempFile, Libro.Existencias);
end;

close(txt);
close(tempFile);

// Borra y renombra
erase(txt); 
rename(tempFile, 'NuevoLibro.txt'); 

// Registra el préstamo en Prestamo.txt
assign(txt, 'Prestamo.txt');
append(txt); // Abre el archivo para añadir al final

writeln(txt, cedulaPrestamo);
writeln(txt, Prestamo.Titulo);
writeln(txt, Prestamo.autor);
writeln(txt, DateToStr(Date())); // Fecha actual como FechaSalida
writeln(txt, Libro.NumeroPaginas);
writeln(txt, ''); // FechaDevolucion inicialmente vacía

close(txt);

writeln('El prestamo se ha registrado.');
end;



procedure PrestamosActivos;
var
  txt: Text;
  cedulaStr, numeroPaginasStr: string;
  tempNumeroPaginas: LongInt;
begin
  assign(txt, 'Prestamo.txt');
  reset(txt);
  
  writeln('Prestamos actualmente activos:');
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    
    // Leer NumeroPaginas y FechaDevolucion como strings
    readln(txt, numeroPaginasStr);
    readln(txt, Prestamo.FechaDevolucion);
    
    // Convertir string a LongInt usando Val
    Val(numeroPaginasStr, tempNumeroPaginas);
    Str(tempNumeroPaginas, Prestamo.NumeroPaginas);
    
    writeln('Cedula: ', Prestamo.Cedula);
    writeln('Titulo: ', Prestamo.Titulo);
    writeln('Autor: ', Prestamo.autor);
    writeln('Fecha de salida: ', Prestamo.FechaSalida);
    writeln('Numero de paginas: ', Prestamo.NumeroPaginas);
    writeln('Fecha de devolucion: ', Prestamo.FechaDevolucion);
    writeln('-----------------------------');
  end;
  
  close(txt);
end;


procedure LibrosDisponibles;
begin
  assign(txt, 'NuevoLibro.txt');
  reset(txt);
  
  writeln('Libros disponibles:');
  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);
    readln(txt, Libro.FechaSalida);
    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);
    
    writeln('Titulo: ', Libro.Titulo);
    writeln('Autor: ', Libro.autor);
    writeln('Fecha de salida: ', Libro.FechaSalida);
    writeln('Numero de paginas: ', Libro.NumeroPaginas);
    writeln('Existencias: ', Libro.Existencias);
    writeln('-----------------------------');
  end;
  
  close(txt);
end;

procedure AlumnosSancionados;
begin
  assign(txt, 'Personas.txt');
  reset(txt);
  
  writeln('Alumnos sancionados:');
  while not eof(txt) do
  begin
    readln(txt, Estudiante.nombre);
    readln(txt, Estudiante.apellido);
    readln(txt, Estudiante.Edad);
    readln(txt, Estudiante.Cedula);
    readln(txt, Estudiante.Carrera);
    
    readln(txt, sancionadoStr);
    
    Estudiante.Sancionado := sancionadoStr = 'True';
    
    if Estudiante.Sancionado then
    begin
      writeln('Nombre: ', Estudiante.nombre, ' ', Estudiante.apellido);
      writeln('Cedula: ', Estudiante.Cedula);
      writeln('Carrera: ', Estudiante.Carrera);
      writeln('-----------------------------');
    end;
  end;
  
  close(txt);
end;

procedure Renovacion;
var
  encontrado: Boolean;
  cedula: integer;
  tempPrestamo: tPrestamo;
  tempEstudiante: tEstudiantes;
  tempFileName: string;
begin
  encontrado := False;
  
  assign(txt, 'Prestamo.txt');
  reset(txt);
  
  writeln('Ingresar la cedula: ');
  readln(cedula);  
  
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    if Prestamo.Cedula = cedula then
    begin
      encontrado := True;
      break;
    end;
  end;
  
  close(txt);
  
  if encontrado then
  begin
    writeln('Se ha reiniciado su contador de prestamos!');
  end
  else
  begin
    writeln('No cuenta con prestamos activos.');
  end;
end;

procedure Devolucion;
var
  encontrado: Boolean;
  cedula: integer;
  tempPrestamo: tPrestamo;
  tempEstudiante: tEstudiantes;
  tempFileName: string;
begin
  encontrado := False;

  writeln('Ingrese su cedula: ');
  readln(cedula);

  // Eliminar préstamos asociados con la cédula ingresada
  assign(txt, 'Prestamo.txt');
  reset(txt);
  
  assign(tempFile, 'TempPrestamo.txt');
  rewrite(tempFile);
  
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    if Prestamo.Cedula <> cedula then
    begin
      writeln(tempFile, Prestamo.Cedula);
      writeln(tempFile, Prestamo.Titulo);
      writeln(tempFile, Prestamo.autor);
      writeln(tempFile, Prestamo.FechaSalida);
      writeln(tempFile, Prestamo.NumeroPaginas);
      writeln(tempFile, Prestamo.FechaDevolucion);
    end
    else
    begin
      encontrado := True;
    end;
  end;
  
  close(txt);
  close(tempFile);
  
  erase(txt);
  rename(tempFile, 'Prestamo.txt');

  if encontrado then
  begin
    // Actualizar el estado de préstamos activos en el archivo de estudiantes
    assign(txt, 'Personas.txt');
    reset(txt);

    assign(tempFile, 'TempPersonas.txt');
    rewrite(tempFile);

    while not eof(txt) do
    begin
      readln(txt, tempEstudiante.nombre);
      readln(txt, tempEstudiante.apellido);
      readln(txt, tempEstudiante.Edad);
      readln(txt, tempEstudiante.Cedula);
      readln(txt, tempEstudiante.Carrera);
      readln(txt, sancionadoStr);
      
      if tempEstudiante.Cedula = cedula then
      begin
        sancionadoStr := 'False';
      end;

      writeln(tempFile, tempEstudiante.nombre);
      writeln(tempFile, tempEstudiante.apellido);
      writeln(tempFile, tempEstudiante.Edad);
      writeln(tempFile, tempEstudiante.Cedula);
      writeln(tempFile, tempEstudiante.Carrera);
      writeln(tempFile, sancionadoStr);
    end;

    close(txt);
    close(tempFile);
    
    erase(txt);
    rename(tempFile, 'Personas.txt');

    writeln('Prestamo devuelto.');
  end
  else
  begin
    writeln('No cuenta con prestamos activos.');
  end;
end;


procedure IngresarNuevoLibro;
begin
  assign(txt, 'NuevoLibro.txt');
  append(txt);
  
  writeln('Ingrese el Titulo del Libro: ');
  readln(Libro.Titulo);
  writeln('Ingrese el Autor del Libro: ');
  readln(Libro.autor);
  writeln('Ingrese la Fecha de salida del Libro: ');
  readln(Libro.FechaSalida);
  writeln('Ingrese el Numero de paginas del Libro: ');
  readln(Libro.NumeroPaginas);
  writeln('Ingrese las existencias del Libro: ');
  readln(Libro.Existencias);
  
  writeln(txt, Libro.Titulo);
  writeln(txt, Libro.autor);
  writeln(txt, Libro.FechaSalida);
  writeln(txt, Libro.NumeroPaginas);
  writeln(txt, Libro.Existencias);
  
  close(txt);
  writeln('Libro registrado con éxito.');
end;

procedure Menu;
begin
 writeln;
	clrscr;
	writeln('[]= = = = = = = = = = = = = = = = = =[]');
	writeln('|                                     |');
	writeln('|1)REGISTRAR NUEVO ALUMNO             |');
	writeln('|                                     |');
	writeln('|2)REGISTRAR PRESTAMOS                |');
	writeln('|                                     |');
	writeln('|3)PRESTAMOS ACTIVOS                  |');
	writeln('|                                     |');
	writeln('|4)LIBROS DISPONIBLES                 |');
	writeln('|                                     |');
	writeln('|5)ALUMNOS SANCIONASDOS               |');
	writeln('|                                     |');
	writeln('|6)RENOVACION                         |');
	writeln('|                                     |');
	writeln('|7)DEVOLUCION                         |');
	writeln('|                                     |');
	writeln('|8)INGRESAR NUEVO LIBRO               |');
	writeln('|                                     |');
	writeln('|9)SALIR                              |');
	writeln('|                                     |');
	writeln('[]= = = = = = = = = = = = = = = = = =[]');
end;

begin
  repeat
    Menu;
    readln(opcion);
    case opcion of
      1: RegistrarNuevoAlumno;
      2: RegistrarPrestamo;
      3: PrestamosActivos;
      4: LibrosDisponibles;
      5: AlumnosSancionados;
      6: Renovacion;
      7: Devolucion;
      8: IngresarNuevoLibro;
    end;
  until opcion = 9;
end.

  tEstudiantes = record
    nombre: string[30];
    apellido: string[30];
    Edad: LongInt;
    Cedula: LongInt;
    Carrera: String[30];
    Sancionado: boolean;
  end;

type
  tPrestamo = record
    Cedula: integer;
    Titulo: string[30];
    autor: string[30];
    FechaSalida: string[30];
    NumeroPaginas: string[30];
    FechaDevolucion: string[30];
  end;

type
  tLibro = record
    Titulo: string[30];
    autor: string[30];
    FechaSalida: string[30];
    NumeroPaginas: string[30];
    Existencias: integer;
  end;

var
  opcion: integer;
  Estudiante: tEstudiantes;
  Prestamo: tPrestamo;
  Libro: tLibro;
  txt: Text;
  sancionadoStr: string;

procedure RegistrarNuevoAlumno;
var
  inputStr: AnsiString;
begin
  assign(txt, 'Personas.txt');
  append(txt);
  writeln('Ingrese su nombre: ');
  readln(Estudiante.nombre);
  writeln('Ingrese su apellido: ');
  readln(Estudiante.apellido);
  writeln('Ingrese su edad: ');
  readln(inputStr);
  while not TryStrToInt(inputStr, Estudiante.Edad) do
  begin
    writeln('Ingrese un numero valido: ');
    readln(inputStr);
  end;
  writeln('Ingrese su cedula: ');
  readln(inputStr);
  while not TryStrToInt(inputStr, Estudiante.Cedula) do
  begin
    writeln('La cedula es invalida. Ingrese un numero de cedula valido: ');
    readln(inputStr);
  end;
  writeln('Ingrese la carrera del estudiante: ');
  readln(Estudiante.Carrera);
  Estudiante.Sancionado := False;
  writeln(txt, Estudiante.nombre);
  writeln(txt, Estudiante.apellido);
  writeln(txt, Estudiante.Edad);
  writeln(txt, Estudiante.Cedula);
  writeln(txt, Estudiante.Carrera);
  writeln(txt, Estudiante.Sancionado);
  close(txt);
  writeln('La información del alumno ha sido guardada con exito.');
end;

procedure RegistrarPrestamo;
var
  encontrado, libroDisponible, tienePrestamoActivo: Boolean;
  cedulaPrestamo, dias: integer;
begin
  encontrado := False;
  libroDisponible := False;
  tienePrestamoActivo := False;
  
  assign(txt, 'Personas.txt');
  reset(txt);
  writeln('Ingrese su cedula para registrar el prestamo: ');  
  readln(cedulaPrestamo);  
  while not eof(txt) do
  begin
    readln(txt, Estudiante.nombre);
    readln(txt, Estudiante.apellido);
    readln(txt, Estudiante.Edad);
    readln(txt, Estudiante.Cedula);
    readln(txt, Estudiante.Carrera);
    readln(txt, sancionadoStr);
    Estudiante.Sancionado := sancionadoStr = 'True';
  
    if Estudiante.Cedula = cedulaPrestamo then
    begin
      encontrado := True;
      break;
    end;
  end;
  close(txt);
  
  if not encontrado then
  begin
    writeln('El alumno no se encuentra registrado.');
    Exit;
  end;

  // Validar si el estudiante tiene algún préstamo activo
  assign(txt, 'Prestamo.txt');
  reset(txt);
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    if Prestamo.Cedula = cedulaPrestamo then
    begin
      tienePrestamoActivo := True;
      break;
    end;
  end;
  close(txt);
  
  if tienePrestamoActivo then
  begin
    writeln('El alumno ya cuenta con un prestamo activo.');
    writeln('¿Hace cuantos días tiene el libro?');
    readln(dias);
    
    if dias > 3 then
    begin
      Estudiante.Sancionado := True;
      assign(txt, 'Personas.txt');
      reset(txt);
      assign(txt, 'TempPersonas.txt');
      rewrite(txt);
      
      while not eof(txt) do
      begin
        readln(txt, Estudiante.nombre);
        readln(txt, Estudiante.apellido);
        readln(txt, Estudiante.Edad);
        readln(txt, Estudiante.Cedula);
        readln(txt, Estudiante.Carrera);
        readln(txt, sancionadoStr);
        
        if Estudiante.Cedula = cedulaPrestamo then
          sancionadoStr := 'True';
        
        writeln(txt, Estudiante.nombre);
        writeln(txt, Estudiante.apellido);
        writeln(txt, Estudiante.Edad);
        writeln(txt, Estudiante.Cedula);
        writeln(txt, Estudiante.Carrera);
        writeln(txt, sancionadoStr);
      end;
      
      close(txt);
      assign(txt, 'TempPersonas.txt');
      rename(txt, 'Personas.txt');
    end;
  end;

  assign(txt, 'NuevoLibro.txt');
  reset(txt);
  writeln('Ingrese el Titulo del Libro: ');  
  readln(Prestamo.Titulo);
  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);
    readln(txt, Libro.FechaSalida);
    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);
    
    if Libro.Titulo = Prestamo.Titulo then
    begin
      libroDisponible := Libro.Existencias > 0;
      break;
    end;
  end;
  close(txt);
  
  if not libroDisponible then
  begin
    writeln('El libro seleccionado no está disponible.');
    Exit;
  end;
  
  assign(txt, 'Prestamo.txt');
  append(txt);
    
  writeln('Ingrese el Autor del Libro: ');
  readln(Prestamo.autor);
  writeln('Ingrese la Fecha de salida del Libro: ');
  readln(Prestamo.FechaSalida);
  writeln('Ingrese el Numero de paginas del Libro: ');
  readln(Prestamo.NumeroPaginas);
  Prestamo.FechaDevolucion := '';
    
  writeln(txt, cedulaPrestamo); 
  writeln(txt, Prestamo.Cedula);
  writeln(txt, Prestamo.Titulo);
  writeln(txt, Prestamo.autor);
  writeln(txt, Prestamo.FechaSalida);
  writeln(txt, Prestamo.NumeroPaginas);
  writeln(txt, Prestamo.FechaDevolucion);
  
  // Actualizar las existencias del libro
  assign(txt, 'NuevoLibro.txt');
  reset(txt);
  assign(txt, 'NuevoLibroTemp.txt');
  rewrite(txt);
  
  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);
    readln(txt, Libro.FechaSalida);
    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);
    
    if Libro.Titulo = Prestamo.Titulo then
      Dec(Libro.Existencias);
    
    writeln(txt, Libro.Titulo);
    writeln(txt, Libro.autor);
    writeln(txt, Libro.FechaSalida);
    writeln(txt, Libro.NumeroPaginas);
    writeln(txt, Libro.Existencias);
  end;
  
  close(txt);
  assign(txt, 'NuevoLibroTemp.txt');
  rename(txt, 'NuevoLibro.txt');
  
  close(txt);
  writeln('Préstamo registrado con éxito.');
end;

procedure PrestamosActivos;
begin
  assign(txt, 'Prestamo.txt');
  reset(txt);
  
  writeln('Préstamos activos:');
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    writeln('Cedula: ', Prestamo.Cedula);
    writeln('Titulo: ', Prestamo.Titulo);
    writeln('Autor: ', Prestamo.autor);
    writeln('Fecha de salida: ', Prestamo.FechaSalida);
    writeln('Numero de paginas: ', Prestamo.NumeroPaginas);
    writeln('Fecha de devolución: ', Prestamo.FechaDevolucion);
    writeln('-----------------------------');
  end;
  
  close(txt);
end;

procedure LibrosDisponibles;
begin
  assign(txt, 'NuevoLibro.txt');
  reset(txt);
  
  writeln('Libros disponibles:');
  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);
    readln(txt, Libro.FechaSalida);
    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);
    
    writeln('Titulo: ', Libro.Titulo);
    writeln('Autor: ', Libro.autor);
    writeln('Fecha de salida: ', Libro.FechaSalida);
    writeln('Numero de paginas: ', Libro.NumeroPaginas);
    writeln('Existencias: ', Libro.Existencias);
    writeln('-----------------------------');
  end;
  
  close(txt);
end;

procedure AlumnosSancionados;
begin
  assign(txt, 'Personas.txt');
  reset(txt);
  
  writeln('Alumnos sancionados:');
  while not eof(txt) do
  begin
    readln(txt, Estudiante.nombre);
    readln(txt, Estudiante.apellido);
    readln(txt, Estudiante.Edad);
    readln(txt, Estudiante.Cedula);
    readln(txt, Estudiante.Carrera);
    
    readln(txt, sancionadoStr);
    
    Estudiante.Sancionado := sancionadoStr = 'True';
    
    if Estudiante.Sancionado then
    begin
      writeln('Nombre: ', Estudiante.nombre, ' ', Estudiante.apellido);
      writeln('Cedula: ', Estudiante.Cedula);
      writeln('Carrera: ', Estudiante.Carrera);
      writeln('-----------------------------');
    end;
  end;
  
  close(txt);
end;

procedure Renovacion;
var
  encontrado: Boolean;
  cedula: integer;
begin
  encontrado := False;
  
  assign(txt, 'Prestamo.txt');
  reset(txt);
  
  writeln('Ingrese la Cedula del alumno: ');
  readln(cedula);  
  
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    if Prestamo.Cedula = cedula then
    begin
      encontrado := True;
      break;
    end;
  end;
  
  close(txt);
  
  if encontrado then
  begin
    writeln('el prestamo se ha renovado exitosamente.');
  end
  else
  begin
    writeln('El alumno no se encuentra con prestamos activos.');
  end;
end;

procedure Devolucion;
var
  encontrado: Boolean;
  cedula: integer;
begin
  encontrado := False;
  
  assign(txt, 'Prestamo.txt');
  reset(txt);
  
  writeln('Ingrese la Cedula del alumno: ');
  readln(cedula);  
  
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
    readln(txt, Prestamo.FechaSalida);
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);
    
    if Prestamo.Cedula = cedula then
    begin
      encontrado := True;
      break;
    end;
  end;
  
  close(txt);
  
  if encontrado then
  begin
    writeln('Prestamo devuelto con exito.');
  end
  else
  begin
    writeln('El alumno no tiene prestamos activos.');
  end;
end;

procedure IngresarNuevoLibro;
begin
  assign(txt, 'NuevoLibro.txt');
  append(txt);
  
  writeln('Ingrese el Titulo del Libro: ');
  readln(Libro.Titulo);
  writeln('Ingrese el Autor del Libro: ');
  readln(Libro.autor);
  writeln('Ingrese la Fecha de salida del Libro: ');
  readln(Libro.FechaSalida);
  writeln('Ingrese el Numero de paginas del Libro: ');
  readln(Libro.NumeroPaginas);
  writeln('Ingrese las existencias del Libro: ');
  readln(Libro.Existencias);
  
  writeln(txt, Libro.Titulo);
  writeln(txt, Libro.autor);
  writeln(txt, Libro.FechaSalida);
  writeln(txt, Libro.NumeroPaginas);
  writeln(txt, Libro.Existencias);
  
  close(txt);
  writeln('Libro registrado con exito.');
end;


begin
  repeat
    Menu;
    readln(opcion);
    case opcion of
      1: RegistrarNuevoAlumno;
      2: RegistrarPrestamo;
      3: PrestamosActivos;
      4: LibrosDisponibles;
      5: AlumnosSancionados;
      6: Renovacion;
      7: Devolucion;
      8: IngresarNuevoLibro;
    end;
  until opcion = 9;
end.
