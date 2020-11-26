using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public static class Mapper
    {
        public static TC_Persona AlumnoEntityToTC_Persona(AlumnoEntity alumnoEntity)
        {
            TC_Persona persona = new TC_Persona();

            return persona;
        }

        public static TC_Alumno AlumnoEntityToTC_Alumno(AlumnoEntity alumnoEntity)
        {            
            TC_Alumno alumno = new TC_Alumno();

            return alumno;
        }

        public static FacultadDTO TC_FacultadToFacultadDTO(TC_Facultad facultad)
        {
            FacultadDTO facultadDTO = new FacultadDTO();

            return facultadDTO;
        }

        public static EscuelaDTO TC_EscuelaToEscuelaDTO(TC_Escuela escuela)
        {
            EscuelaDTO escuelaDTO = new EscuelaDTO();

            return escuelaDTO;
        }

        public static EspecialidadDTO TC_EspecialidadToEspecialidadDTO(TC_Especialidad especialidad)
        {
            EspecialidadDTO especialidadDTO = new EspecialidadDTO();

            return especialidadDTO;
        }
    }
}
