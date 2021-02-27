using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Types;
using Domain.Entities;
using ExcelDataReader;

namespace Domain.Helpers
{
    public class MatriculaExcelSource : IMatriculaSource
    {
        readonly string[] expectedColNames = { "Cod_rc", "Cod_alu", "Año", "P", "Est_mat", "Nivel", "Es_ingresa", "Cred_desap" };

        public List<DataMatriculaType> GetList(string filePath)
        {
            var dataMatriculas = new List<DataMatriculaType>();

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
                                    reader.GetValue(3)?.ToString(),
                                    reader.GetValue(4)?.ToString(),
                                    reader.GetValue(5)?.ToString(),
                                    reader.GetValue(6)?.ToString(),
                                    reader.GetValue(7)?.ToString()
                                };

                                if (!expectedColNames.SequenceEqual(colNames))
                                    throw new Exception("Las columnas no son las esperadas");
                                i++;
                            }
                            else
                            {
                                dataMatriculas.Add(Mapper.MatriculaReader_To_DataMatriculaType(reader));
                            }
                        }

                        
                    } while (reader.NextResult());
                }
            }

            return dataMatriculas;
        }
    }
}
