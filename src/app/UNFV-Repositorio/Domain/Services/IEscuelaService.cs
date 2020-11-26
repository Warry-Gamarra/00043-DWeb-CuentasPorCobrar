using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IEscuelaService
    {
        IEnumerable<EscuelaDTO> GetAll();

        IEnumerable<EscuelaDTO> GetByFac(string codFac);

        EscuelaDTO GetByID(string codEsc, string codFac);
    }
}
