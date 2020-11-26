using Data.DTO;
using Data.Procedures;
using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IAlumnoRepository
    {
        IEnumerable<TC_Alumno> GetAll();

        ResponseData Create(TC_Alumno alumno);

        ResponseData Edit(TC_Alumno alumno);
    }
}
