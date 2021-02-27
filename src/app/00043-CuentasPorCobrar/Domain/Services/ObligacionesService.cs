using Data;
using Data.Procedures;
using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public class ObligacionesService
    {
        public Response Generar_Obligaciones_Pregrado(int cmbAnio, int cmbPeriodo)
        {
            ResponseData result;

            var generarObligaciones = new USP_IU_GenerarObligacionesPregrado_X_Ciclo()
            {
                I_Anio = cmbAnio,
                I_Periodo = cmbPeriodo,
                I_UsuarioCre = 0
            };

            result = generarObligaciones.Execute();

            return new Response(result);
        }
    }
}
