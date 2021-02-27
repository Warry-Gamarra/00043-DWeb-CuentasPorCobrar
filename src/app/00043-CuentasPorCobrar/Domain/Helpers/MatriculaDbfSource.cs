using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Types;
using Domain.Entities;
using NDbfReader;

namespace Domain.Helpers
{
    public class MatriculaDbfSource : IMatriculaSource
    {
        public List<DataMatriculaType> GetList(string filePath)
        {
            var dataMatriculas = new List<DataMatriculaType>();

            using (var table = Table.Open(filePath))
            {
                var reader = table.OpenReader(Encoding.ASCII);
                
                while (reader.Read())
                {
                    dataMatriculas.Add(Mapper.MatriculaReader_To_DataMatriculaType(reader));
                }
            }

            return dataMatriculas;
        }
    }
}
