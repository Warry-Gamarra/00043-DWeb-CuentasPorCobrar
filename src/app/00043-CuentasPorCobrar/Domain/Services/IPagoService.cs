using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IPagoService
    {
        bool ValidarCodOperacion(string C_CodOperacion, int I_EntidadFinanID, DateTime? D_FecPago);
        void GrabarRegistroArchivo();
    }
}
