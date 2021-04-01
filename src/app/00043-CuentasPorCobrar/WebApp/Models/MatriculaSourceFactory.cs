using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebApp.Models
{
    public class MatriculaSourceFactory
    {
        public static IMatriculaSource GetMatriculaSource(string extension)
        {
            IMatriculaSource matriculaSource;

            switch (extension.ToLower())
            {
                case ".dbf":
                    matriculaSource = new MatriculaDbfSource();
                    break;

                case ".xls":
                    matriculaSource = new MatriculaExcelSource();
                    break;

                case ".xlsx":
                    matriculaSource = new MatriculaExcelSource();
                    break;

                default:
                    throw new Exception("Tipo de archivo desconocido.");
            }

            return matriculaSource;
        }
    }
}
