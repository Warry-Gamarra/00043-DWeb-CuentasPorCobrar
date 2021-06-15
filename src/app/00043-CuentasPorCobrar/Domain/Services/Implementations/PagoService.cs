using Data.Procedures;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class PagoService : IPagoService
    {
        public bool validarCodOperacion(string C_CodOperacion, int I_EntidadFinanID, DateTime? D_FecPago)
        {
            var spParams = new USP_S_ValidarCodOperacion()
            {
                C_CodOperacion = C_CodOperacion,
                I_EntidadFinanID = I_EntidadFinanID,
                D_FecPago = D_FecPago
            };

            return USP_S_ValidarCodOperacion.Execute(spParams);
        }
    }
}
