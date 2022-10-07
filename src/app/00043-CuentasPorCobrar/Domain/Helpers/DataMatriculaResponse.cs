using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public class DataMatriculaResponse
    {
        public DataMatriculaResponse()
        {
            DataMatriculasObs = new List<MatriculaObsEntity>();
        }

        public DataMatriculaResponse(List<MatriculaObsEntity> dataMatriculasObs)
        {
            this.DataMatriculasObs = dataMatriculasObs;

            Success = true;

            Message = "La importación de data de matrícula ha finalizado.";

            if (DataMatriculasObs.Count > 0)
                Message = Message + " Se ha encontrado: " + DataMatriculasObs.Count.ToString() +
                    " observacion(es). Haga <a href='cargar-aptos/resultado'>click aquí</a> para descargar la lista de observaciones.";
        }

        public bool Success { get; set; }

        public string Message { get; set; }

        public List<MatriculaObsEntity> DataMatriculasObs { get; set; }
    }
}
