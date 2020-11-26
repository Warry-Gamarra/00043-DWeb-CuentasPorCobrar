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
    }
}
