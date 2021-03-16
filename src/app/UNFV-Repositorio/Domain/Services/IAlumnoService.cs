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
        ServiceResponse Create(AlumnoEntity alumnoEntity);

        ServiceResponse Edit(AlumnoEntity alumnoEntity);

        IEnumerable<AlumnoDTO> GetAll();

        IEnumerable<AlumnoDTO> GetByDocIdent(string codTipDoc, string numDNI);

        AlumnoDTO GetByID(string codRc, string codAlu);

        IEnumerable<AlumnoDTO> GetByCodAlu(string codAlu);
    }
}
