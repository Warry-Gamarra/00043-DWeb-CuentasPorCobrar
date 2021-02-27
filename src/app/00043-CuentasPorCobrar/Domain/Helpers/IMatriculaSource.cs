using Data.Types;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    interface IMatriculaSource
    {
        List<DataMatriculaType> GetList(string filePath);
    }
}
