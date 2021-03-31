using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Domain.Entities;
using NDbfReader;

namespace WebApp.Models
{
    public class MatriculaDbfSource : IMatriculaSource
    {
        public List<MatriculaEntity> GetList(string filePath)
        {
            var dataMatriculas = new List<MatriculaEntity>();

            using (var table = Table.Open(filePath))
            {
                var reader = table.OpenReader(Encoding.ASCII);
                
                while (reader.Read())
                {
                    dataMatriculas.Add(Mapper.MatriculaReader_To_MatriculaEntity(reader));
                }
            }

            return dataMatriculas;
        }
    }
}
