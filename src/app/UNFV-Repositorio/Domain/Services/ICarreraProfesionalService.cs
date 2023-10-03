using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ICarreraProfesionalService
    {
        IEnumerable<CarreraProfesionalDTO> GetByFac(string codFac);

        IEnumerable<CarreraProfesionalDTO> GetByEsc(string codEsc, string codFac);

        CarreraProfesionalDTO GetByID(string codRc);

        IEnumerable<CarreraProfesionalDTO> GetAll();
    }
}
