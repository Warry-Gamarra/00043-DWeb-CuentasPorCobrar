using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IEspecialidadService
    {
        IEnumerable<EspecialidadDTO> GetByEsc(string codEsc, string codFac);

        EspecialidadDTO GetByID(string codEsp, string codEsc, string codFac);
    }
}
