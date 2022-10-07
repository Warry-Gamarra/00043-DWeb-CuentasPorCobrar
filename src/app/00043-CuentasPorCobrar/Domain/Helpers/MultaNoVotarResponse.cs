using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public class MultaNoVotarResponse
    {
        public MultaNoVotarResponse()
        {
            MultasSinRegistrar = new List<MultaNoVotarSinRegistrarEntity>();
        }

        public MultaNoVotarResponse(List<MultaNoVotarSinRegistrarEntity> multasSinRegistrar)
        {
            this.MultasSinRegistrar = multasSinRegistrar;

            Success = true;

            Message = "El registro de los alumnos que no votaron ha finalizado.";

            if (MultasSinRegistrar.Count > 0)
                Message = Message + " Se ha encontrado: " + MultasSinRegistrar.Count.ToString() +
                    " observacion(es). Haga <a href='cargar-multas-pregrado/resultado'>click aquí</a> para descargar la lista de observaciones.";
        }

        public bool Success { get; set; }

        public string Message { get; set; }

        public List<MultaNoVotarSinRegistrarEntity> MultasSinRegistrar { get; set; }
    }
}
