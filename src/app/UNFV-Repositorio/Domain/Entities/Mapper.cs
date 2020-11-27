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
            FacultadDTO facultadDTO = new FacultadDTO()
            {
                CodFac = facultad.C_CodFac,
                FacDesc = facultad.T_FacDesc,
                FacAbrev = facultad.T_FacAbrev,
                Habilitado = facultad.B_Habilitado
            };

            return facultadDTO;
        }

        public static EscuelaDTO TC_EscuelaToEscuelaDTO(TC_Escuela escuela)
        {
            EscuelaDTO escuelaDTO = new EscuelaDTO()
            {
                CodEsc = escuela.C_CodEsc,
                CodFac = escuela.C_CodFac,
                EscDesc = escuela.T_EscDesc,
                EscAbrev = escuela.T_EscAbrev,
                Habilitado = escuela.B_Habilitado
            };

            return escuelaDTO;
        }

        public static EspecialidadDTO TC_EspecialidadToEspecialidadDTO(TC_Especialidad especialidad)
        {
            EspecialidadDTO especialidadDTO = new EspecialidadDTO()
            {
                CodEsp = especialidad.C_CodEsp,
                CodEsc = especialidad.C_CodEsc,
                CodFac = especialidad.C_CodFac,
                EspDesc = especialidad.T_EspDesc,
                EspAbrev = especialidad.T_EspAbrev,
                Habilitado = especialidad.B_Habilitado
            };

            return especialidadDTO;
        }
    }
}
