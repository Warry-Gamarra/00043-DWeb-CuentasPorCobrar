using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.UnfvRepositorioClient
{
    public interface IProgramasClient
    {
        IEnumerable<FacultadModel> GetFacultades();

        IEnumerable<EscuelaModel> GetEscuelas(string codFac);
    }
}
