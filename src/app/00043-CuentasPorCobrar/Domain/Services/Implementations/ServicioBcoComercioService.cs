using Data.Tables;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ServicioBcoComercioService : IServicioBcoComercioService
    {
        public readonly int ObligacionPregrado = 1;

        private readonly int ObligacionPosgrado = 1;

        private readonly int BCPTasas = 22;

        private int[] serviciosExcluidos()
        {
            return new int[] { ObligacionPregrado, ObligacionPosgrado, BCPTasas };
        }

        public IEnumerable<ServicioBcoComercioDto> listaServiciosBcoComercioTasa()
        {
            var lista = TC_Servicios.GetAll().Where(s => !serviciosExcluidos().Contains(s.I_ServicioID));

            var result = lista.Select(s => new ServicioBcoComercioDto()
            {
                I_ServicioID = s.I_ServicioID,
                T_DescServ = s.T_DescServ,
                C_CodServicio = s.C_CodServicio,
                B_Habilitado = s.B_Habilitado
            });

            return result;
        }
    }
}
