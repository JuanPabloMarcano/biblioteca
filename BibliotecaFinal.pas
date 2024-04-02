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
    NumeroPaginas: string[30];
    FechaDevolucion: string[30];
  end;
  
  type
  tPersona = record
    nombre: string[30];
    apellido: string[30];
    Edad: Integer;
    Cedula: Integer;
    Carrera: string[30];
    Sancionado: Boolean;
  end;

var
  Persona: tPersona;

type
  tLibro = record
    Titulo: string[30];
    autor: string[30];
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
   currentDir: string;

procedure CrearArchivoSiNoExiste(nombreArchivo: string);
var
  archivo: Text;
begin
  if not FileExists(nombreArchivo) then
  begin
    Assign(archivo, nombreArchivo);
    Rewrite(archivo);
    Close(archivo);
  end;
end;

procedure RegistrarNuevoAlumno;
var
  inputStr: AnsiString;
  cedulaExistente: Boolean;
  tempEstudiante: tEstudiantes;
begin
ClrScr; 
  CrearArchivoSiNoExiste('Personas.txt');

  assign(txt, 'Personas.txt');
  reset(txt);
  if IOResult <> 0 then
  begin
    writeln('Error al abrir el archivo.');
    Exit;
  end;

  cedulaExistente := False;

  writeln('Ingrese la Cedula: ');
  readln(inputStr);
  while not TryStrToInt(inputStr, Estudiante.Cedula) do
  begin
    writeln('Cedula invalida. Ingrese un numero valido: ');
    readln(inputStr);
  end;

  while not eof(txt) do
  begin
    readln(txt, tempEstudiante.nombre);
    readln(txt, tempEstudiante.apellido);
    readln(txt, tempEstudiante.Edad);
    readln(txt, tempEstudiante.Cedula);
    readln(txt, tempEstudiante.Carrera);
    readln(txt, sancionadoStr);
    tempEstudiante.Sancionado := sancionadoStr = 'True';

    if Estudiante.Cedula = tempEstudiante.Cedula then
    begin
      cedulaExistente := True;
      break;
    end;
  end;

  close(txt);

  if cedulaExistente then
  begin
    writeln('La cedula ingresada ya esta registrada.');
    Exit;
  end;

  assign(txt, 'Personas.txt');
  append(txt);

   writeln('----------------------------------');
   writeln('Ingrese los datos del alumno: ');
   writeln('----------------------------------');
   writeln('Ingrese el nombre: ');
  readln(Estudiante.nombre);
  writeln('----------------------------------');
  writeln('Ingrese el apellido: ');
  readln(Estudiante.apellido);
  writeln('----------------------------------');
    writeln('Ingrese La edad: ');
  readln(inputStr);
  while not TryStrToInt(inputStr, Estudiante.Edad) do
  begin
    writeln('Edad invalida. Ingrese un numero válido: ');
    readln(inputStr);
  end;
  writeln('----------------------------------');
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
  writeln('Se han registrado los datos del alumno con exito.');
end;


//   PROCEDURE REGISTRAR PRESTAMO   //

procedure RegistrarPrestamo;
var
  encontrado, libroDisponible, tienePrestamoActivo: Boolean;
  cedulaPrestamo, diasPrestamo: integer;
  txt, tempFile: Text;
  cedulas: array of integer;
  i: Integer;
begin
ClrScr; 
  CrearArchivoSiNoExiste('Personas.txt');
  CrearArchivoSiNoExiste('Prestamo.txt');
  CrearArchivoSiNoExiste('NuevoLibro.txt');

  encontrado := False;
  libroDisponible := False;
  tienePrestamoActivo := False;

  // Buscar al estudiante
  assign(txt, 'Personas.txt');
  reset(txt);
  if IOResult <> 0 then
  begin
    writeln('Error al abrir el archivo.');
    Exit;
  end;

  writeln('Ingrese su cedula para realizar el prestamo: ');  
  readln(cedulaPrestamo);

  SetLength(cedulas, 0); // Inicializar array vacío

  while not eof(txt) do
  begin
    readln(txt, Estudiante.nombre);
    readln(txt, Estudiante.apellido);
    readln(txt, Estudiante.Edad);
    readln(txt, Estudiante.Cedula);
    readln(txt, Estudiante.Carrera);
    readln(txt, sancionadoStr);
    Estudiante.Sancionado := sancionadoStr = 'True';

    // Guardar la cédula en el array
    SetLength(cedulas, Length(cedulas) + 1);
    cedulas[High(cedulas)] := Estudiante.Cedula;

    if Estudiante.Cedula = cedulaPrestamo then
    begin
      encontrado := True;
      break;
    end;
  end;
  close(txt);

  // Comparar la cédula ingresada con las cédulas guardadas en el array
  if not encontrado then
  begin
    for i := 0 to High(cedulas) do
    begin
      if cedulas[i] = cedulaPrestamo then
      begin
        encontrado := True;
        break;
      end;
    end;
  end;

  if not encontrado then
  begin
    writeln('El alumno no esta registrado.');
    Exit;
  end;

  // Solicitar días del préstamo
  writeln('Hace cuantos dias sacaste el libro?');
  readln(diasPrestamo);

  // Validar si el estudiante tiene algún préstamo activo
  assign(txt, 'Prestamo.txt');
  reset(txt);
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Prestamo.Titulo);
    readln(txt, Prestamo.autor);
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
    if diasPrestamo > 3 then
    begin
      writeln('Tu usuario ha sido sancionado, no puedes pedir mas libros prestados.');
      
      // Actualizar archivo de estudiantes con sanción
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
    
    if Estudiante.Cedula = cedulaPrestamo then
      Estudiante.Sancionado := True;

    writeln(tempFile, Estudiante.nombre);
    writeln(tempFile, Estudiante.apellido);
    writeln(tempFile, Estudiante.Edad);
    writeln(tempFile, Estudiante.Cedula);
    writeln(tempFile, Estudiante.Carrera);
    writeln(tempFile, Estudiante.Sancionado);
    
    // Verificar si hay más líneas para leer antes de intentar leer
    if not eof(txt) then
      readln(txt); // Leer línea en blanco entre registros
end;

close(txt);
close(tempFile);

erase(txt);  // Borra el archivo original
rename(tempFile, 'Personas.txt');  // Renombra el archivo temporal al nombre original
      
      Exit;  // Salir de la función y regresar al menú principal
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
    writeln('El libro seleccionado no esta disponible.');
    Exit;
  end;

  // Actualizar las existencias del libro
  assign(txt, 'NuevoLibro.txt');
  reset(txt);

  assign(tempFile, 'NuevoLibroTemp.txt');
  rewrite(tempFile);

  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);
    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);
    
    if Libro.Titulo = Prestamo.Titulo then
      Dec(Libro.Existencias);
    
    writeln(tempFile, Libro.Titulo);
    writeln(tempFile, Libro.autor);
    writeln(tempFile, Libro.NumeroPaginas);
    writeln(tempFile, Libro.Existencias);
  end;

  close(txt);
  close(tempFile);

  erase(txt);  // Borra el archivo original
  rename(tempFile, 'NuevoLibro.txt');  // Renombra el archivo temporal al nombre original

  // Registrar préstamo en Prestamo.txt
  assign(txt, 'Prestamo.txt');
  append(txt); // Abre el archivo para añadir al final

  writeln(txt, cedulaPrestamo);
  writeln(txt, Libro.Titulo);
  writeln(txt, Libro.autor);
  writeln(txt, Libro.NumeroPaginas);
  writeln(txt, ''); // FechaDevolucion inicialmente vacía

  close(txt);

  writeln('Prestamo registrado con exito.');
end;





//   PROCEDURE PRESTAMOS ACTIVOS   //

procedure PrestamosActivos;
var
  txt: Text;
  cedulaStr, numeroPaginasStr: string;
  tempNumeroPaginas: LongInt;
begin

ClrScr; 
  CrearArchivoSiNoExiste('Prestamo.txt');


  assign(txt, 'Prestamo.txt');
  reset(txt);

  writeln('Prestamos activos:');
  while not eof(txt) do
  begin
    readln(txt, Prestamo.Cedula);
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);


    // Leer NumeroPaginas y FechaDevolucion como strings
    readln(txt, numeroPaginasStr);
    readln(txt, Prestamo.FechaDevolucion);

    // Convertir string a LongInt usando Val
    Val(numeroPaginasStr, tempNumeroPaginas);
    Str(tempNumeroPaginas, Prestamo.NumeroPaginas);

    writeln('Cedula: ', Prestamo.Cedula);
    writeln('Titulo: ', Libro.Titulo);
    writeln('Autor: ', Libro.autor);

    writeln('Numero de paginas: ', Libro.NumeroPaginas);

    writeln('-----------------------------');
    readln;
    ClrScr; 
  end;

  close(txt);
end;


// PROCEDURE LIBROS DISPONIBLES //

procedure LibrosDisponibles;
begin
ClrScr; 

  CrearArchivoSiNoExiste('NuevoLibro.txt');
  assign(txt, 'NuevoLibro.txt');
  reset(txt);

  writeln('Libros disponibles:');
  while not eof(txt) do
  begin
    readln(txt, Libro.Titulo);
    readln(txt, Libro.autor);

    readln(txt, Libro.NumeroPaginas);
    readln(txt, Libro.Existencias);

    writeln('Titulo: ', Libro.Titulo);
    writeln('Autor: ', Libro.autor);

    writeln('Numero de paginas: ', Libro.NumeroPaginas);
    writeln('Existencias: ', Libro.Existencias);
    writeln('-----------------------------');
  end;
readln;
ClrScr; 
  close(txt);
end;

// PROCEDURE ALUMNOS SANCIONADOS //

procedure AlumnosSancionados;
var
  txt: Text;
  sancionadoStr: String;
begin
ClrScr; 
  CrearArchivoSiNoExiste('Personas.txt');

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

    // Verificar si el estudiante está sancionado
    if sancionadoStr = 'TRUE' then
    begin
      writeln('Nombre: ', Estudiante.nombre, ' ', Estudiante.apellido);
      writeln('Cedula: ', Estudiante.Cedula);
      writeln('Carrera: ', Estudiante.Carrera);
      writeln('Sancionado: ', sancionadoStr);
      writeln('-----------------------------');
    end;
  end;
readln;
ClrScr; 
  close(txt);
end;



//   PROCEDURE RENOVACION //

procedure Renovacion;
var
  encontrado: Boolean;
  cedula: integer;
  tempPrestamo: tPrestamo;
  tempEstudiante: tEstudiantes;
  tempFileName: string;
begin

ClrScr; 
  CrearArchivoSiNoExiste('Prestamo.txt');

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
    writeln('se ha reiniciado su contador de prestamos');
  end
  else
  begin
    writeln('El alumno no tiene prestamos activos.');
    readln;
    ClrScr; 
    
  end;
end;


//   PROCEDURE DEVOLUCION   //

procedure Devolucion;
var
  encontrado, teniaSancionAntes: Boolean;
  cedula: integer;
  tempPrestamo: tPrestamo;
  tempEstudiante: tEstudiantes;
  tempFileName: string;
  sancionadoStr: string;  // Variable para almacenar el estado de sanción como string
begin
ClrScr; 
  CrearArchivoSiNoExiste('Prestamo.txt');

  encontrado := False;
  teniaSancionAntes := False;  // Variable para verificar si el estudiante tenía una sanción antes de devolver el libro

  writeln('Ingrese la Cedula del alumno: ');
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
    readln(txt, Prestamo.NumeroPaginas);
    readln(txt, Prestamo.FechaDevolucion);

    if Prestamo.Cedula <> cedula then
    begin
      writeln(tempFile, Prestamo.Cedula);
      writeln(tempFile, Prestamo.Titulo);
      writeln(tempFile, Prestamo.autor);
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

  // Verificar el estado de sanción antes de devolver el libro
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
      if sancionadoStr = 'True' then
      begin
        teniaSancionAntes := True;
        encontrado := True;
      end;
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

  if encontrado = True then
  begin
    if teniaSancionAntes then
    begin
      writeln('Prestamos devueltos con exito y se ha quitado la sancion');
    end
    else
    begin
      writeln('Prestamos devueltos con exito.');
    end;
  end
  else
  begin
    writeln('El alumno no tiene préstamos activos.');
  end;
end;



//   PROCEDURE INGRESAR NUEVO LIBRO   //

procedure IngresarNuevoLibro;
var
  respuesta: String;
  txt: Text;
begin
ClrScr; 
  writeln('Es usted el encargado? (Si/No)');
  readln(respuesta);

  if LowerCase(respuesta) <> 'si' then
  begin
    writeln('Solo el encargado puede crear nuevos libros');
    Exit; // Salir del procedimiento si no es el encargado
  end;

  CrearArchivoSiNoExiste('NuevoLibro.txt');
  assign(txt, 'NuevoLibro.txt');
  append(txt);

  writeln('Ingrese el Titulo del Libro: ');
  readln(Libro.Titulo);
  writeln('Ingrese el Autor del Libro: ');
  readln(Libro.autor);

  writeln('Ingrese el Numero de paginas del Libro: ');
  readln(Libro.NumeroPaginas);
  writeln('Ingrese las existencias del Libro: ');
  readln(Libro.Existencias);

  writeln(txt, Libro.Titulo);
  writeln(txt, Libro.autor);
  writeln(txt, Libro.NumeroPaginas);
  writeln(txt, Libro.Existencias);

  close(txt);
  writeln('Libro registrado con exito.');
end;



procedure Menu;

begin

	textcolor(lightcyan);
	writeln('[]= = = = = = = = = = = = = = = = = =[]');
	writeln('|                                     |');
	writeln('|                                     |');
	writeln('|                                     |');
	writeln('|             BIBLIOTECA              |');
	writeln('|                                     |');
	writeln('|  UNIVERSIDAD ALMA MATER DEL CARIBE  |');
	writeln('|                                     |');
	writeln('|                                     |');
	writeln('|                                     |');
	writeln('[]= = = = = = = = = = = = = = = = = =[]');
	writeln;
	writeln('Presione "ENTER", para continuar');
	readln;
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
	writeln('|9)Salir                              |');
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
      9: writeln('Gracias por la visita');
    end;
  until opcion = 9;
end.


