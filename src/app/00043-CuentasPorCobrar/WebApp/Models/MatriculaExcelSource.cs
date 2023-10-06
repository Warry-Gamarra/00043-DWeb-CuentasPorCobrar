using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Domain.Entities;
using Domain.Helpers;
using ExcelDataReader;

namespace WebApp.Models
{
    public class MatriculaExcelSource : IMatriculaSource
    {
        readonly string[] expectedColPregrado = { "Cod_rc", "Cod_alu", "Año", "P", "Est_mat", "Nivel", "Es_ingresa", "Cred_desap", "Cod_curso", "Vez" };

        readonly string[] expectedColPosgrado = { "Cod_rc", "Cod_alu", "Año", "P", "Est_mat", "Nivel", "Es_ingresa", "Cred_desap" };

        public List<MatriculaEntity> GetList(TipoAlumno tipoAlumno, string filePath)
        {
            var dataMatriculas = new List<MatriculaEntity>();

            string[] colNames;

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
                                switch (tipoAlumno)
                                {
                                    case TipoAlumno.Pregrado:
                                        colNames = new string[]
                                            {
                                                reader.GetValue(0)?.ToString(),
                                                reader.GetValue(1)?.ToString(),
                                                reader.GetValue(2)?.ToString(),
                                                reader.GetValue(3)?.ToString(),
                                                reader.GetValue(4)?.ToString(),
                                                reader.GetValue(5)?.ToString(),
                                                reader.GetValue(6)?.ToString(),
                                                reader.GetValue(7)?.ToString(),
                                                reader.GetValue(8)?.ToString(),
                                                reader.GetValue(9)?.ToString()
                                            };

                                        if (!expectedColPregrado.SequenceEqual(colNames))
                                            throw new Exception("Las columnas no son las esperadas");

                                        break;

                                    case TipoAlumno.Posgrado:
                                        colNames = new string[]
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
                                        
                                        if (!expectedColPosgrado.SequenceEqual(colNames))
                                            throw new Exception("Las columnas no son las esperadas");

                                        break;

                                    case TipoAlumno.SegundaEspecialidad:
                                        colNames = new string[]
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

                                        if (!expectedColPosgrado.SequenceEqual(colNames))
                                            throw new Exception("Las columnas no son las esperadas");

                                        break;

                                    case TipoAlumno.Residentado:
                                        colNames = new string[]
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

                                        if (!expectedColPosgrado.SequenceEqual(colNames))
                                            throw new Exception("Las columnas no son las esperadas");

                                        break;

                                    default:
                                        throw new Exception("Tipo de archivo incorrecto");
                                }
                                
                                i++;
                            }
                            else
                            {
                                dataMatriculas.Add(Mapper.MatriculaReader_To_MatriculaEntity(tipoAlumno, reader));
                            }
                        }

                        
                    } while (reader.NextResult());
                }
            }

            return dataMatriculas;
        }
    }
}
