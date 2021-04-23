using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class AlumnosSinVotoSourceFactory
    {
        public static IAlumnosSinVotoSource Get(string extension)
        {
            IAlumnosSinVotoSource alumnosSinVotoSource;

            switch (extension.ToLower())
            {
                case ".xls":
                    alumnosSinVotoSource = new AlumnosSinVotoExcelSource();
                    break;

                case ".xlsx":
                    alumnosSinVotoSource = new AlumnosSinVotoExcelSource();
                    break;

                default:
                    throw new Exception("Tipo de archivo desconocido.");
            }

            return alumnosSinVotoSource;
        }
    }
}