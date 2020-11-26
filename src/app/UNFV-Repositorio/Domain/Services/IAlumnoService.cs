using Data.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IAlumnoService
    {
        IEnumerable<AlumnoEntity> GetAll();

        ResponseData Create(AlumnoEntity alumnoEntity);

        ResponseData Edit(AlumnoEntity alumnoEntity);
    }
}
