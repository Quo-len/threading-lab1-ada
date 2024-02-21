with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Calendar; use Ada.Calendar;

procedure Main is
   Num_Of_Threads : Integer := 2;
   Num_Of_Seconds : Integer;

   Stop_Threads : Boolean := False;
   pragma Atomic(Stop_Threads);

   task type Halt is
      entry Start (Num : Integer);
   end Halt;

   task body Halt is
      Delay_Duration : Integer;
   begin
      accept Start (Num : Integer) do
         Delay_Duration := Num;
      end Start;
      Put_Line("Calculating...");
      delay Duration'Value(Delay_Duration'Img);
      Put_Line("Interrupting tasks.");
      Stop_Threads := true;
   end Halt;


   task type Abacus is
      entry Start (Num1: Integer; Num2: Integer);
   end Abacus;

   task body Abacus is
      Sum : Long_Long_Integer := 0; -- Initialize Sum as Float
      Steps : Integer:= 0;
      ID : Integer;
      Step : Integer;
   begin
      accept Start (Num1: Integer; Num2: Integer) do
         ID := Num1;
         Step := Num2;
      end Start;
      loop
         Sum := Sum + Long_Long_Integer'Value(Step'Img);
         Steps := Steps + 1;
         exit when Stop_Threads;
      end loop;
      Put_Line("Thread " & ID'Img & ": Sum = " & Sum'Img & " Steps = " & Steps'Img);
   end Abacus;

   type AbacusArr is array (Integer range <>) of Abacus;
   type StepTaskArray is array (Integer range <>) of Integer;

   Halting : Halt;
   Step : Integer;
begin
   Put_Line("Enter number of threads:");
   Num_Of_Threads := Integer'Value(Get_Line);  -- Read a line of text from the console

   Put_Line("Enter duration of calculation:");
   Num_Of_Seconds := Integer'Value(Get_Line);  -- Read a line of text from the console

   declare
      Threads: AbacusArr (1 .. Num_Of_Threads);
      Steps : StepTaskArray (1 .. Num_Of_Threads);
   begin
      for I in Threads'Range loop
         Put_Line("Enter step for thread " & Integer'Image(I) & ":");
         Step := Integer'Value(Get_Line);
         Steps(I) := Step;
      end loop;

      for I in Threads'Range loop
         Threads(I).Start(I, Steps(I));
      end loop;
      Halting.Start(Num_Of_Seconds); -- Start halt task
   end;
end Main;
