using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using Domain.Entities;
using ExcelDataReader;

namespace WebApp.Models
{
    public class AlumnosSinVotoExcelSource : IAlumnosSinVotoSource
    {
        readonly string[] expectedColNames = { "Año", "p", "Cod_alu", "Cod_rc" };

        public List<AlumnoSinVotoEntity> GetList(string filePath)
        {
            var alumnosSinVoto = new List<AlumnoSinVotoEntity>();

            using (var stream = File.Open(filePath, FileMode.Open, FileAccess.Read))
            {
                using (var reader = ExcelReaderFactory.CreateReader(stream))
                {
                    do
                    {
                        int i = 0;

                        while (reader.Read())
                        {
                            if (i == 0)
                            {
                                string[] colNames =
                                {
                                    reader.GetValue(0)?.ToString(),
                                    reader.GetValue(1)?.ToString(),
                                    reader.GetValue(2)?.ToString(),
                                    reader.GetValue(3)?.ToString()
                                };

                                if (!expectedColNames.SequenceEqual(colNames))
                                    throw new Exception("Las columnas no son las esperadas");
                                i++;
                            }
                            else
                            {
                                alumnosSinVoto.Add(Mapper.MatriculaReader_To_AlumnoSinVotoEntity(reader));
                            }
                        }


                    } while (reader.NextResult());
                }
            }

            return alumnosSinVoto;
        }
    }
}